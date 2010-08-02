require 'magento/base'

module Mage
  class User < Mage::Base
    
    ADMIN = 'Administrator'
    
    attr_accessor :user_name,  :first_name , :last_name, :email, :password, :role
    cattr_accessor :uri
    
    def isAdmin?
      role.eql?(ADMIN)
    end
    
    def admin
      all.select{|u| u.isAdmin?}
    end
    
    def role_create!
      mage_role = AdminRole.find_by_role_name(role) || AdminRole.new
      mage_role.update_attributes(
        :parent_id  => 0, 
        :tree_level => 1,
        :sort_order => 0,
        :role_type  => 'G', 
        :user_id    => 0,
        :role_name  => role )  
    end
    
    def user_create!
      mage_user = AdminUser.find_by_username(username)
      mage_user.update_attributes(
        :firstname  => first_name, 
        :lastname   => last_name, 
        :email      => email, 
        :username   => user_name,
        :password   => Mage.password(password), 
        :created    => Time.new, 
        :modified   => Time.new, 
        :logdate    => nil, 
        :lognum     => 0, 
        :reload_acl_flag => 0, 
        :is_active => 1)
      
      mage_role = AdminRole.find_by_role(role)
      
      unless mage_role.nil?
        user_role = AdminRole.find(:conditions => {:user_id => mage_user.id, :role_name => role})
        user_role.update_attributes(
          :parent_id  => mage_role.id,
          :tree_level => 2,
          :sort_order => 0,
          :role_type  => 'U',
          :user_id    => mage_user.id,
          :role_name  => role)
      end
    end
    
  end
end