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
    
    def find_attribute(attribute_code)
      attribute = EavAttribute.find_by_attribute_code(attribute_code)
      if attribute.nil?
        EavAttribute.create(
        :entity_type_id => ,
        :attribute_model =>, 
        :backend_model =>,
        :backend_type =>,
        :backend_table =>,
        :frontend_model =>,
        :frontend_input =>,
        :frontend_label =>, 
        :frontend_class =>, 
        :source_model =>, 
        :is_required =>, 
        :is_user_defined =>, 
        :default_value =>, 
        :is_unique =>, 
        :note =>,)
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