require 'magento/base'

module Mage
  class User
    
    ADMIN = 'Administrator'
    
    cattr_accessor :uri
    attr_accessor :user_name,  :first_name , :last_name, :email, :password, :role
    
    def self.all
      @@all ||= Mage.grab_remote_data uri
    end
    
    def isAdmin?
      role.eql?(Mage::User.ADMIN)
    end
    
    def admins
      all.select{|u| u.isAdmin?}
    end
    
  end
end