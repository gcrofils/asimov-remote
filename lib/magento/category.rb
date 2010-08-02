require 'magento/base'

module Mage
  class Category < Mage::Base
    
    attr_accessor :parent_url_key, :name, :url_key, :description, :page_title, :meta_keywords, :meta_description, :is_active
    cattr_accessor :uri
    attr_accessor :api
    
    def create!
      puts "TODO..."
    end

  end
end