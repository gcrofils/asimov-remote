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
      %x[php -r '#{cmd.gsub('\'','"')}']
    end
    
    def php_format(options = {})
      options.collect{|k,v| "'#{k}' => '#{v.nil? ? '' : v.gsub("'") {"\\'"}}'"}.join(',')
    end
    
  end
  
  
  class Base
    
    def self.find(filter)
      obj = self.name.constantize.new
      obj.send(filter)
    end  
    
    def all
      logger.debug " #{self.class.name} ==> all"
      @all ||= load_remote
    end
    
    def load_remote
      data = grab_remote_data
      parseCSV(data)
    end
    
    def grab_remote_data(retries=3)
      logger.debug "READ #{uri} #{self.class.name}"
      i = 0
      while i < retries
        begin
          i = i.succ
          break open(uri).read
        rescue Exception => e
          logger.warn "Remote Data failed ! with exception #{e} #{"will not retry." if i.eql?(retries)}"
          sleep 2 unless i.eql?(retries)
        end
      end
    end
    
    def parseCSV(data)
      ret = Array.new
      begin
        datas = CSV.parse(data)
        attributes = datas.shift
        attributes.collect!{|attr| attr.dehumanize}
        datas.each do |row|
          obj = self.class.new
          i = 0
          row.each do |col|
            begin
              m = attributes[i][-2,2].eql?('[]') ? "#{attributes[i]}_add" : "#{attributes[i]}="
              obj.send(m.to_sym ,col.nil? ? nil : col.strip)
            rescue NoMethodError
              logger.warn "#{self.class.name} Undefined attribute #{attributes[row.index(col)]} >#{col.strip unless col.nil?}<"
            end
            i = i.succ
          end
          ret << obj
        end
      rescue Exception => e
        puts e.to_s
      end
      ret
    end
    
  end
end