require 'magento/base'

module Mage
  class Product < Mage::Base
    
    attr_accessor :sku, :name , :description, :short_description, :price, :meta_title, :meta_keywords, :meta_description, :qty, :tax_class_id, :type, :set, :weight, :categories
    cattr_accessor :uri
    attr_accessor :api
    
    def category_add(url_key)
      @categories = [] if @categories.nil?
      @categories << api.find_category_by_url_key(url_key)
    end
    
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
                     
       alias :id :sku
       alias :id= :sku=
       
                     
  def initialize(id = nil)
    @id = @sku = id
  end
  

  end

end