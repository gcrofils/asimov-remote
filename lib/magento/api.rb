require 'magento/base'
require 'savon'

# catalog_category_assign_product
# catalog_category_assigned_products
# catalog_category_attribute_current_store
# catalog_category_attribute_list
# catalog_category_attribute_options
# catalog_category_create
# catalog_category_current_store
# catalog_category_delete
# catalog_category_info
# catalog_category_level
# catalog_category_move
# catalog_category_remove_product
# catalog_category_tree
# catalog_category_update
# catalog_category_update_product
# catalog_inventory_stock_item_list
# catalog_inventory_stock_item_update
# catalog_product_attribute_current_store
# catalog_product_attribute_list
# catalog_product_attribute_media_create
# catalog_product_attribute_media_current_store
# catalog_product_attribute_media_info
# catalog_product_attribute_media_list
# catalog_product_attribute_media_remove
# catalog_product_attribute_media_types
# catalog_product_attribute_media_update
# catalog_product_attribute_options
# catalog_product_attribute_set_list
# catalog_product_attribute_tier_price_info
# catalog_product_attribute_tier_price_update
# catalog_product_create
# catalog_product_current_store
# catalog_product_delete
# catalog_product_get_special_price
# catalog_product_info
# catalog_product_link_assign
# catalog_product_link_attributes
# catalog_product_link_list
# catalog_product_link_remove
# catalog_product_link_types
# catalog_product_link_update
# catalog_product_list
# catalog_product_set_special_price
# catalog_product_type_list
# catalog_product_update
# customer_address_create
# customer_address_delete
# customer_address_info
# customer_address_list
# customer_address_update
# customer_customer_create
# customer_customer_delete
# customer_customer_info
# customer_customer_list
# customer_customer_update
# customer_group_list
# directory_country_list
# directory_region_list
# end_session
# global_faults
# login
# resource_faults
# resources
# sales_order_add_comment
# sales_order_cancel
# sales_order_hold
# sales_order_info
# sales_order_invoice_add_comment
# sales_order_invoice_cancel
# sales_order_invoice_capture
# sales_order_invoice_create
# sales_order_invoice_info
# sales_order_invoice_list
# sales_order_invoice_void
# sales_order_list
# sales_order_shipment_add_comment
# sales_order_shipment_add_track
# sales_order_shipment_create
# sales_order_shipment_get_carriers
# sales_order_shipment_info
# sales_order_shipment_list
# sales_order_shipment_remove_track
# sales_order_unhold
# start_session



module Mage
  class Api
    
    API_DEFAULT_RULES = <<END_RULES
 allow | all                               
 deny  | catalog                           
 deny  | catalog/category                  
 deny  | catalog/category/create           
 deny  | catalog/category/delete           
 deny  | catalog/category/info             
 deny  | catalog/category/move             
 deny  | catalog/category/product          
 deny  | catalog/category/product/assign   
 deny  | catalog/category/product/remove   
 deny  | catalog/category/product/update   
 deny  | catalog/category/tree             
 deny  | catalog/category/update           
 deny  | catalog/product                   
 deny  | catalog/product/attribute         
 deny  | catalog/product/attribute/read    
 deny  | catalog/product/attribute/write   
 deny  | catalog/product/create            
 deny  | catalog/product/delete            
 deny  | catalog/product/info              
 deny  | catalog/product/link              
 deny  | catalog/product/link/assign       
 deny  | catalog/product/link/remove       
 deny  | catalog/product/link/update       
 deny  | catalog/product/media             
 deny  | catalog/product/media/create      
 deny  | catalog/product/media/remove      
 deny  | catalog/product/media/update      
 deny  | catalog/product/update            
 deny  | catalog/product/update_tier_price 
 deny  | cataloginventory                  
 deny  | cataloginventory/info             
 deny  | cataloginventory/update           
 deny  | customer                          
 deny  | customer/address                  
 deny  | customer/address/create           
 deny  | customer/address/delete           
 deny  | customer/address/info             
 deny  | customer/address/update           
 deny  | customer/create                   
 deny  | customer/delete                   
 deny  | customer/info                     
 deny  | customer/update                   
 deny  | directory                         
 deny  | directory/country                 
 deny  | directory/region                  
 deny  | sales                             
 deny  | sales/order                       
 deny  | sales/order/change                
 deny  | sales/order/info                  
 deny  | sales/order/invoice               
 deny  | sales/order/invoice/cancel        
 deny  | sales/order/invoice/capture       
 deny  | sales/order/invoice/comment       
 deny  | sales/order/invoice/create        
 deny  | sales/order/invoice/info          
 deny  | sales/order/invoice/void          
 deny  | sales/order/shipment              
 deny  | sales/order/shipment/comment      
 deny  | sales/order/shipment/create       
 deny  | sales/order/shipment/info         
 deny  | sales/order/shipment/track
END_RULES

  attr_accessor :role_name, :first_name, :last_name, :email, :user_name, :password, :rules
  
  def sessionId
    @sessionId ||= client.login { |soap| soap.body = { :username => "admin", :api_key => "secret09" } }.to_hash[:login_response][:login_return]
  end
  
  def client
    @client ||= Savon::Client.new "http://delhaye.milizone.com/api/v2_soap?wsdl=1"
  end
  
  def create_category(options = {})
    puts "session ID : #{sessionId}"
    response = client.catalog_category_create do |soap|
     soap.body = { :session_id => 'fea893bd379046f0416407078dd4c4c4', :parent_id => options[:parent_id], :category_data => options}
   end
   pp response
  end  

  def initialize
      @role_name  = 'CatalogManager'
      @first_name = 'api_user'
      @last_name   = 'api_user'
      @email      = 'apiuser@example.org'
      @user_name  = ''
      @password   = ''
      @rules      = CSV.parse(API_DEFAULT_RULES, "|")
  end
  
  def create_role
    @role = ApiRole.find_by_role_name(role_name) || ApiRole.new
    @role.update_attributes( 
      :parent_id => 0, 
      :tree_level => 1, 
      :sort_order => 0, 
      :role_type => 'G', 
      :user_id => 0, 
      :role_name => role_name
     )
     create_rules
  end
    
   def create_user(options = {})
     @user_name = options[:user_name]
     @password  = options[:password]
     
     @user = ApiUser.find_by_username(user_name) || ApiUser.new
     @user.update_attributes(
     :firstname => first_name, 
     :lastname => last_name, 
     :email => email, 
     :username => user_name, 
     :api_key => Mage.password(password), 
     :created => Time.new, 
     :modified => Time.new, 
     :lognum => 0, 
     :reload_acl_flag => 0, 
     :is_active => 1
     )
     
     parent_id = ApiRole.find_by_role_name(role_name).id
     
     @role = ApiRole.find_by_role_name(user_name) || ApiRole.new
     @role.update_attributes( 
      :parent_id => parent_id, 
      :tree_level => 2, 
      :sort_order => 0, 
      :role_type => 'U', 
      :user_id => @user.id, 
      :role_name => user_name
     )
  end
 
  def create_rules
    rules.each do |permission, resource_id|
      rule = ApiRule.find(:first, :conditions => {:role_id => @role.id, :resource_id => resource_id.strip }) || ApiRule.new
      rule.update_attributes(
        :role_id => @role.id, 
        :resource_id => resource_id.strip, 
        :privileges => '', 
        :assert_id => 0, 
        :role_type => 'G', 
        :permission => permission.strip)
    end
  end
    
  end
end