require 'magento/base'
require 'gdata'
require 'tmpdir' 
require "base64"

module Mage
  class Image
    
    attr_accessor :configuration
    
    def initialize(config)
      @configuration = config
    end
    
    def load_images(api)
      fetch_picasa
      pattern = /\/([_@a-zA-Z0-9]*)-\[((base)?\+?(small)?\+?(thumbnail)?)\]-(.*).jpg$/
      Dir["#{imgtmpdir}/*"].select { |file| pattern =~ file }.each do |file|
        logger.debug "try to attach #{file}"
        m     = pattern.match file
        sku   = m[1].gsub('_', ' ').gsub('@','/')
        types = mage_types(m)
        unless types.size.eql?(0)
          image = {:file => 
                        { :name     => m[6],
                          :content  => Base64.encode64(File.read(file)),
                          :mime     => 'image/jpeg'
                        },
                      :label => m[6].gsub('_', ' '),
                      :position => 1,
                      :types => types,
                      :exclude => (types.include?('image') ? '0' : '1')
                    }
          api.create_product_media({:sku => sku, :image => image})
        end        
      end
    end
      
    def fetch_picasa
      logger.debug "Fetch Picasa #{configuration.picasa_user}"
      photos.each do |photo|
        logger.debug "retrieve #{imgtmpdir}/#{photo[:title]}"
        response = client.get photo[:url]
        File.open(File.join(imgtmpdir,photo[:title]), 'w') {|f| f.write response.body}
      end
    end


private

    def uri
      "http://picasaweb.google.com/data/feed/api/user/#{configuration.picasa_user}/albumid/#{configuration.picasa_album}?kind=photo&imgmax=d"
    end
  
    def client_login(retries = 3)
      client = GData::Client::Photos.new
      i = 0
      while i < retries
        i = i.succ
        begin
          client.clientlogin(configuration.picasa_user, configuration.picasa_pwd)
          return client
        rescue  GData::Client::ServerError
          logger.warn "Picasa Server error#{", retrying" unless i.eql?(retries)}"
        rescue  GData::Client::AuthorizationError
          logger.error "Picasa Authorization error login:#{configuration.picasa_user}, pwd:#{configuration.picasa_pwd}"
          i = retries
        rescue Exception => e
          logger.warn "Picasa Login failed ! #{e.to_s.strip} #{"will not retry." if i.eql?(retries)}"
        end
          sleep 2 unless i.eql?(retries)
      end 
      logger.error "Picasa Login Failed !"
      raise ApiLoginFailed   
    end
    
    def client
      @client ||= client_login
    end
  
    def photos
      photos = []
      begin
        feed = client.get(uri).to_xml
        feed.elements.each('entry') do |entry|
          next unless entry.elements['gphoto:id']
          next unless entry.elements['media:group']
          photo = { :id => entry.elements['gphoto:id'].text,
                    :album_id => entry.elements['gphoto:albumid'].text,
                    :title => entry.elements['title'].text }
          entry.elements['media:group'].elements.each('media:content') do |content|
            photo[:url] = content.attribute('url').value
          end
          photos << photo
        end
      rescue ApiLoginFailed
      rescue Exception => e
        logger.error "Picasa retrieve photo failed ! #{e.to_s.strip}"
      end
      photos
    end

    def imgtmpdir
      @imgtmpdir ||= Dir.mktmpdir 
    end
    
    def mage_types(m)
      types = []
      (3..5).each do |i|
        types << mage_type(m[i]) unless mage_type(m[i]).nil?
      end
      types
    end
    
    def mage_type(code)
      case code
        when 'base'
          'image'
        when 'small'
          'small_image'
        when 'thumbnail'
          'thumbnail'
        else
          nil
      end
    end
  end
end




