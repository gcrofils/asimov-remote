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
  
  class ApiLoginFailed < StandardError #:nodoc:
    end
  
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

  attr_accessor :role_name, :first_name, :last_name, :email, :user_name, :password, :rules, :wsdlv2, :wsdl
  
  def sessionId
    @sessionId ||= client_login
  end
  
  def configuration
    @configuration ||= load_configuration
  end
  
  def wsdlv2
    "http://#{configuration.domain}/api/v2_soap?wsdl=1"
  end
  
  def wsdl  
    "http://#{configuration.domain}/api/?wsdl"
  end
    
    
    def load_configuration
      Settings.configuration['magento'].flatten!
    end
  
  def client_login(retries = 3)
    logger.debug "Mage::Api.client_login #{user_name}"
    i = 0
    while i < retries
      i = i.succ
      begin
        response = client.login { |soap| soap.body = { :username => user_name, :api_key => password } }
        logger.debug response.inspect
        return response.to_hash[:login_response][:login_return] unless (response.http_error? or response.soap_fault?)
        logger.warn "Api Login failed ! #{response.http_error} #{response.soap_fault} #{"will not retry." if i.eql?(retries)}"
      rescue Exception => e
        logger.warn "Api Login failed ! #{e} #{"will not retry." if i.eql?(retries)}"
      end
      sleep 2 unless i.eql?(retries)
    end
    raise ApiLoginFailed
  end
  
  def client
    @client ||= Savon::Client.new wsdlv2
  end
  
  def create_category(options = {}, retries = 3)
    logger.debug "#Mage::Api.create_category #{options[:name]}"
    category_id = 0
    i = 0
    while category_id.eql?(0) and i < retries
      logger.warn "#Mage::Api.create_category create category #{options[:name]} failed!" if i > 0
      i = i.succ
      cmd = "$client = new SoapClient('#{wsdl}');"
      cmd += "echo $client->call('#{sessionId}', 'category.create', array (#{options[:parent_id]}, array (#{Mage.php_format(options)})));"
      category_id = Mage.php(cmd).to_i
    end
    if category_id > 0 
      category = category_info(MageCategory.new(category_id))
      categories << category
    else
      logger.error "#Mage::Api.create_category create category #{options[:name]} failed! Will not retry..."
      logger.debug cmd
    end
    category
  end 
  
  def update_category(option={})
    logger.debug "#Mage::Api.update_category #{options.inspect}"
    # hack savon
    cmd = "$client = new SoapClient('#{wsdl}');"
    cmd += "echo $client->call('#{sessionId}', 'category.update', array (#{options[:parent_id]}, array (#{Mage.php_format(options)})));"
    Mage.php(cmd)
  end
  
  def find_category_by_url_key(url_key)
    categories.select{|c| c.url_key.eql?(url_key)}
  end
  
  def find_category_by_id(id)
    categories.select{|c| c.id.to_i.eql?(id)}
  end
  
  def find_product_by_sku(sku)
    products.select{|p| p.sku.eql?(sku)}
  end

  def categories
    @categories || category_parse(category_tree)
  end

  def parents_ids(category_id)
    @parents_id = []
    get_parents_ids(category_id)
  end

  def get_parents_ids(category_id)
    @parents_id << category_id
    get_parents_ids(find_category_by_id(category_id).first.parent_id.to_i) unless category_id <= 2
    @parents_id
  end
  
  def category_tree
    sessionId #Savon Bug ? Asimov Bug ? Needs to be called once.
    client.catalog_category_tree { |soap| soap.body = { :session_id => sessionId } }.to_hash[:catalog_category_tree_response][:tree]
  end
  
  def category_info(category)
    sessionId
    begin
      client.catalog_category_info { |soap| soap.body = { :session_id => sessionId, :category_id => category.id}}.to_hash[:catalog_category_info_response][:info].each do |k,v|
        category.send "#{k}=",v
      end
    rescue Exception => e
      logger.warn "#Mage::Api.category_info #{e} category not found #{category.inspect}"
    end
    category
  end
  
  def category_parse(category_tree)
    @categories = [] if @categories.nil?
    if category_tree.is_a?(Array)
      category_tree.each{|c| category_parse c} 
    else
      @categories << category_info(MageCategory.new(category_tree[:category_id]))
      category_parse category_tree[:children][:item] unless category_tree[:children][:item].nil?
    end
    @categories
  end
  
  def create_product_media(options = {})
    logger.debug "#Mage::Api.create_product_media #{options[:sku]}"
   # begin
  #    response = client.catalog_product_attribute_media_create do |soap|
  #    soap.body = { :session_id => sessionId, 
  #                  :sku => options[:sku],
  #                  :productData => options
  #                 }
  #  end
  #  if response.http_error? or response.soap_fault?
  #    logger.warn "Create Product Media #{options[:image][:label]} for product #{sku} failed ! #{response.http_error} #{response.soap_fault}"
  #  end
  #rescue Exception => e
  #  puts "KO #{e}"
  #end
    begin
      image = options[:image]
      cmd = "$client = new SoapClient('#{wsdl}');"
      cmd += "echo $client->call('#{sessionId}', 'product_media.create', array ('#{options[:sku]}', array('file'=>array('name' => '#{image[:file][:name]}', 'content' => '#{image[:file][:content]}', 'mime'=> '#{image[:file][:mime]}' ), 'label' => '#{image[:label]}', 'position' => #{image[:position]} , 'types' => array('#{image[:types].join('\',\'')}'), 'exclude' => #{image[:exclude]} )));"
      #logger.debug cmd
      Mage.php(cmd)
    rescue  Exception => e
      logger.warn "Create Product Media #{options[:image][:label]} for product #{sku} failed !"
    end
    
  end
  
  def create_product(options = {})
      logger.debug "#Mage::Api.create_product #{options.inspect}"
      response = client.catalog_product_create do |soap|
        soap.body = { :session_id => sessionId, 
                      :sku => options[:sku],
                      :set => options[:set],
                      :type => options[:type],
                      :productData => options
                     }
      end
      unless response.http_error? or response.soap_fault?
        p = MageProduct.new(:id => response.to_hash[:catalog_product_create_response][:result], :sku => options[:sku])
        products << p
        p
      else
        logger.warn "Create Product #{sku} failed ! #{response.http_error} #{response.soap_fault}"
        nil
      end
  end
  
  def product_stock_update(options={})
    logger.debug "#Mage::Api.product_stock_update #{options.inspect}"
    response = client.catalog_inventory_stock_item_update do |soap|
      soap.body = { :session_id => sessionId, 
                      :product => options[:sku],
                      :data => {:qty => options[:qty], 'is_in_stock' => options[:is_in_stock]}
                     }
      end
      logger.warn "Update Product #{sku} Stock failed ! #{response.http_error} #{response.soap_fault}" if (response.http_error? or response.soap_fault?)
  end
  
  def products
    @products || load_products
  end
  
  def load_products
    sessionId #Savon Bug ? Asimov Bug ? Needs to be called once.
    @products = []
    products = client.catalog_product_list { |soap| soap.body = { :session_id => sessionId } }.to_hash[:catalog_product_list_response][:store_view][:item]
    unless products.nil?
      products = [products] unless products.is_a?(Array)
      products.each {|p| @products << MageProduct.new(:sku => p[:sku], :id => p[:product_id].to_i)}
    end
    @products
  end
  
  def product_assign_category(options={})
    logger.debug "#Mage::Api.product_assign_category #{options.inspect}"
    client.catalog_category_assign_product do |soap|
      soap.body = { :session_id => sessionId, 
                      :sku => options[:sku],
                      :category_id => options[:category_id]
                     }
      end
  end
    
  

  def initialize
      @role_name  = 'CatalogManager'
      @first_name = 'api_user'
      @last_name   = 'api_user'
      @email      = 'apiuser@example.org'
      @user_name  = 'admin'
      @password   = 'secret09'
      @rules      = CSV.parse(API_DEFAULT_RULES, "|")
      Savon::Request.logger = ASIMOV_DEFAULT_LOGGER
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