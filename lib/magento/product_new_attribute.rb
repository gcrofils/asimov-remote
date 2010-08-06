require 'magento/base'

module Mage
  class ProductNewAttribute < Mage::Base
    
    attr_accessor :sku
    cattr_accessor :uri
    attr_accessor :api
    
    def create!
    end
    
    def not_exist?
      true
    end
    
    def parent_exist?
    end
    

  end

end