require 'magento/base'

module Mage
  class Product < Mage::Base
    
    attr_accessor :sku, :name , :description, :short_description, :price, :meta_title, :meta_keywords, :meta_description, :qty, :tax_class_id, :type, :set, :weight, :categories
    cattr_accessor :uri
    attr_accessor :api
    
    def category_add(url_key)
      @categories = [] if @categories.nil?
      @categories << url_key unless url_key.nil?
    end
    
    def upsert!
      options = {
      :name => name.htmlentities, 
      :description => description.lipsum.htmlentities, 
      'short_description' => short_description.lipsum.htmlentities, 
      :price => price, 
      'meta_title' => meta_title.lipsum, 
      'meta_keyword' => meta_keywords.lipsum, 
      'meta_description' => meta_description.lipsum,
      :qty => qty, 
      'tax_class_id' => tax_class_id, 
      :type => type, 
      :set => set, 
      :weight => weight,
      :status => 1, 
      :visibility => 4, 
      :inventory_manage_stock => 1,
      :is_in_stock => 1,
      :use_config_manage_stock => 0,
      :sku => sku
      }
      p = api.find_product_by_sku(sku).first
      p = api.create_product options if p.nil?
      api.product_stock_update options
      categories.each do |url_key| 
        category = api.find_category_by_url_key(url_key).first
        unless category.nil?
          api.parents_ids(category.id.to_i).each do |category_id| 
            begin
              CatalogCategoryProduct.create(:category_id => category_id, :product_id => p.product_id)
            rescue Exception => e
              logger.warn "#Mage::Product.upsert! failed to attach category #{category_id} to product #{name} (id: #{p.product_id}, sku: #{sku}) !"
            end
          end
        end
      end
    end
    
    def not_exist?
      api.find_product_by_sku(sku).first.nil?
    end
    

  end

  # virtual Mage Product (several tables in DB)
  class MageProduct
      attr_accessor  :sku, :product_id
                     
       alias :id :product_id
       alias :id= :product_id=
       
                     
  def initialize(attributes = {})
    @id = @product_id = attributes[:id]
    @sku = attributes[:sku]
  end
  

  end

end