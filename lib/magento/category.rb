require 'magento/base'

module Mage
  class Category < Mage::Base
    
    attr_accessor :parent_id, :parent_url_key, :name, :url_key, :description, :page_title, :meta_keywords, :meta_description, :is_active, :available_sort_by, :default_sort_by
    cattr_accessor :uri
    attr_accessor :api
    
    def create!
      if parent_exist?
        options = { :parent_id => parent_id,
                    :name => name, 
                    :url_key => url_key, 
                    :description => description.lipsum, 
                    'meta_title' => page_title.lipsum, 
                    'meta_keywords' => meta_keywords.lipsum, 
                    'meta_description' => meta_description.lipsum, 
                    :is_active => is_active, 
                    'available_sort_by' => available_sort_by, 
                    'default_sort_by' => default_sort_by}
        api.create_category options
      else
        logger.error "url key #{parent_url_key} not found in catalog"
      end
    end
    
    def not_exist?
      api.find_category_by_url_key(url_key).first.nil?
    end
    
    def parent_exist?
      @parent_id || load_parent
    end
    
    def load_parent
      parent = api.find_category_by_url_key(parent_url_key).first
      @parent_id = parent.id unless parent.nil?
      @parent_id || false
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
                     :description,
                     :custom_layout_update,
                     :page_layout,
                     :custom_design
                     
       alias :id :category_id
       alias :id= :category_id=
       
                     
  def initialize(id = nil)
    @id = @category_id = id
    @available_sort_by = 'name'
    @default_sort_by = 'name'
  end
  

  end

end
