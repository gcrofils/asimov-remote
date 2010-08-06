require 'magento/base'

module Mage
  class Category < Mage::Base
    
    attr_accessor :parent_url_key, :name, :url_key, :description, :page_title, :meta_keywords, :meta_description, :is_active, :available_sort_by, :default_sort_by
    cattr_accessor :uri
    attr_accessor :api
    
    def create!
        parent_category = api.find_category_by_url_key(parent_url_key).first
        if parent_category.nil?
          logger.error "url key #{parent_url_key} not found in catalog"
        else
          options = {:parent_id => parent_category.id, :name => name, :url_key => url_key, :description => description.lipsum, :page_title => page_title.lipsum, :meta_keyword => meta_keywords.lipsum, :meta_description => meta_description.lipsum, :is_active => is_active, :available_sort_by => available_sort_by, :default_sort_by => default_sort_by}
          api.create_category options
        end
    end

  end

  class MageCategory
      attr_accessor  :type, 
                     :available_sort_by,
                     :category_id,
                     :children_count,
                     :parent_id,
                     :default_sort_by,
                     :created_at,
                     :position,
                     :all_children,
                     :children,
                     :display_mode,
                     :name,
                     :url_key,
                     :url_path,
                     :path,
                     :updated_at,
                     :level, 
                     :is_active,
                     :meta_description,
                     :meta_keywords,
                     :meta_title,
                     :description
                     
       alias :id :category_id
       alias :id= :category_id=
       
                     
  def initialize(id = nil)
    @id = @category_id = id
    @available_sort_by = 'name'
    @default_sort_by = 'name'
  end
  

  end

end
