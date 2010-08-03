require 'magento/base'

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

  attr_accessor :role_name, :first_name, :last_name, :email, :user_name, :password, :rules, :role, :user

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
    role = ApiRole.find_by_role_name(role_name) || ApiRole.new
    role.update_attributes( 
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
     
     user = ApiUser.find_by_username(user_name) || ApiUser.new
     user.update_attributes(
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
  end
 
  def create_rules
    puts role.inspect
    
    rules.each do |permission, resource_id|
      rule = ApiRule.find(:first, :conditions => {:role_id => role.id, :resource_id => resource_id.strip }) || ApiRule.new
      rule.update_attributes(
        :role_id => role.id, 
        :resource_id => resource_id.strip, 
        :privileges => '', 
        :assert_id => 0, 
        :role_type => 'G', 
        :permission => permission.strip)
    end
  end
    
  end
end