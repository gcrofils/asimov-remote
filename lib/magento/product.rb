require 'magento/base'

module Mage
  class Product < Mage::Base
    
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

  # virtual Mage Product (several tables in DB)
  class MageProduct
      attr_accessor  :sku
                     
       alias :id :category_id
       alias :id= :category_id=
       
                     
  def initialize(id = nil)
    @id = @sku = id
  end
  

  end

end