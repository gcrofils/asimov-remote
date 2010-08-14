require 'magento/base'

module Mage
  class ProductNewAttribute < Mage::Base
    
    attr_accessor :sku, :new_attributes
    cattr_accessor :uri
    cattr_accessor :headers
    cattr_reader :header_rows
    attr_accessor :api
    
    @@header_rows = 9
    @@headers_parsed = false
    
    def method_missing(meth, *args, &block)
      @new_attributes ||= {}
      @new_attributes[meth.to_s.gsub('=','')] = args.first unless args.first.nil?
    end
    
    def find_attribute(attribute_code)
      return nil if attribute_code.nil?
      attribute = EavAttribute.find_by_attribute_code(attribute_code)
      if attribute.nil?
        att = @@headers[attribute_code]
        attribute = EavAttribute.create(
        :attribute_code => attribute_code,
        :entity_type_id => 4,
        :attribute_model => '',  
        :backend_model => '',    
        :backend_type => att[:is_selectable] ? 'int' : 'varchar',
        :backend_table => '',
        :frontend_model => '', 
        :frontend_input => att[:is_selectable] ? 'select' : 'text' ,
        :frontend_label => attribute_code.humanize,
        :frontend_class => '', 
        :source_model => att[:is_selectable] ? 'eav/entity_attribute_source_table' : '' ,
        :is_required => att[:is_required], 
        :is_user_defined => 1, 
        :default_value => '', 
        :is_unique => 0, 
        :is_required => 0,
        :note => attribute_code.humanize)
        
        EavEntityAttribute.create(
          :entity_type_id => 4, 
          :attribute_set_id => 4, 
          :attribute_group_id => find_attribute_group(att[:group]).id, 
          :attribute_id => attribute.id, 
          :sort_order => 0)
          
        cea = CatalogEavAttribute.new(
          :frontend_input_renderer => '',
          :is_global => 1,
          :is_visible => att[:is_visible], 
          :is_searchable => att[:is_searchable], 
          :is_filterable => att[:is_filterable],
          :is_comparable => att[:is_comparable], 
          :is_visible_on_front => 1,
          :is_html_allowed_on_front => 1, 
          :is_used_for_price_rules => 1,
          :is_filterable_in_search => 1,
          :used_in_product_listing => 1,
          :used_for_sort_by => att[:used_for_sort_by],
          :is_configurable => 1,
          :apply_to => '',
          :is_visible_in_advanced_search => 1,
          :position => 0,
          :is_wysiwyg_enabled => 1,
          :is_used_for_promo_rules => 0
          )
         cea.attribute_id = attribute.id
         cea.save
      end
      attribute
    end
    
    def find_attribute_group(group_name)
      group = EavAttributeGroup.find_by_attribute_group_name(group_name.capitalize)
      if group.nil?
        group = EavAttributeGroup.create(
        :attribute_set_id => 4, 
        :attribute_group_name => group_name.capitalize, 
        :sort_order => 8, 
        :default_id => 0
        )
      end
      group
    end
    
    def find_option_value(attributeId, value)
      eavAttributeOptionValue = EavAttributeOptionValue.find(:first, :conditions => {:value => value, :option_id => EavAttributeOption.find_all_by_attribute_id(attributeId)})
      if eavAttributeOptionValue.nil?
        option =  EavAttributeOption.create(:attribute_id => attributeId, :sort_order => 0)
        eavAttributeOptionValue = EavAttributeOptionValue.create(:option_id => option.id, :store_id => 0, :value => value)
      end
      eavAttributeOptionValue
    end
    
    def create!
      parse_header
      product = CatalogProductEntity.find_by_sku(sku)
      unless product.nil?
        new_attributes.each do |attribute_code, value|
          unless value.nil? or attribute_code.nil?
            eavAttribute = find_attribute(attribute_code)
            klass = "CatalogProductEntity#{eavAttribute.backend_type.capitalize}".constantize
            catalogProductEntity = klass.find(:first, :conditions => {:attribute_id => eavAttribute.id, :entity_id => product.entity_id}) || klass.new
            begin
              catalogProductEntity.update_attributes(
              :entity_type_id => 4, 
              :attribute_id => eavAttribute.id, 
              :store_id => 0, 
              :entity_id => product.entity_id,
              :value => eavAttribute.backend_type.eql?('varchar') ? value : find_option_value(eavAttribute.id, value).id
              )
            rescue Exception => e
              logger.warn "ProductNewAttribute.create! #{e} #{attribute_code} => #{value}"
            end
          end
        end
      end
    end
    
    def parse_header
      unless @@headers_parsed
        ret = {}
        attributes = @@headers.shift
        @@headers.each do |row|
          i = 1
          key = row.shift
          row.each do |col|
            ret[attributes[i]] ||= {}
            ret[attributes[i]][key.to_sym] = col
            i = i.succ
          end
          
        end
        @@headers = ret
      end
      @@headers_parsed = true
    end
    
    def not_exist?
      true
    end
    
    def parent_exist?
    end
    

  end

end