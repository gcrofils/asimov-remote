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
    
  end
  
  
  class Base
    
    def self.find(filter)
      obj = self.name.constantize.new
      obj.send(filter)
    end  
    
    def all
      @all ||= load_remote
    end
    
    def load_remote
      data = grab_remote_data
      parseCSV(data)
    end
    
    def grab_remote_data(retries=3)
      i = 0
      while i < retries
        begin
          i = i.succ
          break open(uri).read
        rescue
          sleep 2 unless i.eql?(retries)
        end
      end
    end
    
    def parseCSV(data)
      all = Array.new
      begin
        datas = CSV.parse(data)
        attributes = datas.shift
        attributes.collect!{|attr| attr.dehumanize}
        datas.each do |row|
          obj = self.class.new
          row.each do |col|
            begin
              obj.send("#{attributes[row.index(col)]}=".to_sym ,col.strip)
            rescue NoMethodError
              puts "#{self.class.name} Undefined attribute #{attributes[row.index(col)]}"
            end
          end
          all << obj
        end
      rescue Exception => e
        puts e.to_s
      end
      all
    end
    
  end
end