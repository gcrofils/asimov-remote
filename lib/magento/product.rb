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
      options = {
      :name => name, 
      :description => description.lipsum, 
      :short_description => short_description.lipsum, 
      :price => price, 
      :meta_title => meta_description.lipsum, 
      :meta_keywords => meta_description.lipsum, 
      :meta_description => meta_description.lipsum, 
      :qty => qty, 
      :tax_class_id => tax_class_id, 
      :type => type, 
      :set => set, 
      :weight => weight,
      :status => 1, 
      :visibility => 4, 
      :inventory_manage_stock => 1,
      :is_in_stock => 1,
      :use_config_manage_stock => 0
      }
      pp api.create_product options
      pp api.product_stock_update options
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