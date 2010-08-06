require 'magento/base'

module Mage
  class ProductNewAttribute < Mage::Base
    
    attr_accessor :sku, :attributes
    cattr_accessor :uri
    attr_accessor :api
    
    def method_missing(meth, *args, &block)
      self.attributes[meth.to_s.gsub('=','')] = args.first unless args.first.nil?
    end
    
    def create!
    end
    
    def not_exist?
      true
    end
    
    def parent_exist?
    end
    

  end

end