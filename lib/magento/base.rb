require 'open-uri'
require 'net/https'
require 'csv'
require 'digest/md5'

module Mage
  
  class << self
    
    def grab_remote_data(uri, retries=3)
      begin
        CSV.parse(open(uri).read)
      rescue
      end
    end
    
  end
  
  
  class Base
    
  end
end