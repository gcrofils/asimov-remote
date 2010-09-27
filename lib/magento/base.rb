require 'open-uri'
require 'net/https'
require 'csv'
require 'digest/md5'

module Mage
  
  class << self
  
    def password(passphrase)
      salt = (0...2).map{65.+(rand(25)).chr}.join
      Digest::MD5.hexdigest("#{salt}#{passphrase}") + ":#{salt}"
    end
    
    #php wrapper
    def php(cmd)
      %x[php -r '#{cmd.gsub('"', '\\"').gsub('\'','"')}']
    end
    
    def php_format(options = {})
      options.collect{|k,v| "'#{k}' => '#{v.nil? ? '' : v.gsub("'") {"\\'"}}'"}.join(',')
    end
    
  end
  
  class RemoteDataLoadingFailed < StandardError #:nodoc:
  end
  
  
  class Base
    
    def self.find(filter)
      obj = self.name.constantize.new
      obj.send(filter)
    end  
    
    def all
      @all ||= load_remote_data
    end
    
    def raw_data(retries=3)
      logger.debug "READ #{uri} #{self.class.name}"
      i = 0
      while i < retries
        begin
          i = i.succ
          @remote_raw_data = open(uri).read
          break @remote_raw_data
        rescue Exception => e
          logger.warn "Reading remote Data failed ! with exception #{e} #{"will not retry." if i.eql?(retries)}"
          sleep 2 unless i.eql?(retries)
        end
      end
    end
    
    def csv_data
      @remote_raw_data ||= raw_data
      raise RemoteDataLoadingFailed if @remote_raw_data.nil?
      CSV.parse(@remote_raw_data)
    end
    
    def load_remote_data
      data = csv_data
      hrows = self.respond_to?(:header_rows) ? header_rows : 0
      self.class.headers = data[0..hrows] if self.respond_to?(:headers)
      csv_to_objects(data[0..0].concat(data[(hrows+1)..data.size]))
    end

    def csv_to_objects(datas)  
      ret = []
      attributes = datas.shift
      attributes.collect!{|attr| attr.dehumanize}
      datas.each do |row|
        obj = self.class.new
        i = 0
        row.each do |col|
          begin
            m = attributes[i][-2,2].eql?('[]') ? "#{attributes[i].gsub('[]','')}_add" : "#{attributes[i]}="
            obj.send(m.to_sym ,col.nil? ? nil : col.strip)
          rescue NoMethodError => e
            logger.warn "#{e} #{self.class.name} #{m} Undefined attribute #{attributes[i]} >#{col.strip unless col.nil?}<"
          end
          i = i.succ
        end
        ret << obj
      end
      ret
    end
    
  end
end