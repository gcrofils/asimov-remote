require 'magento/base'

module Mage
  class ProductNewAttribute < Mage::Base
    
    attr_accessor :sku, :new_attributes
    cattr_accessor :uri
    cattr_accessor :headers
    cattr_reader :header_rows
    attr_accessor :api
    
    @@header_rows = 10
    
    def method_missing(meth, *args, &block)
      @new_attributes ||= {}
      @new_attributes[meth.to_s.gsub('=','')] = args.first unless args.first.nil?
    end
    
    def create_new_attribute
      
    end
    
    def create!
      puts @@headers.inspect
    end
    
    def not_exist?
      true
    end
    
    def parent_exist?
    end
    

  end

end