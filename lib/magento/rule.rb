require 'magento/base'

module Mage
  class Rule < Mage::Base
    
    attr_accessor :rule
    attr_accessor :roles
    attr_accessor :rule_value
    cattr_accessor :uri
    
    def method_missing(meth, *args, &block)
      #if meth.to_s[0..0].eql?('*')
        self.roles ||= Array.new
        self.roles << meth.to_s.gsub('=','').gsub('*','') if !args[0].nil? and args[0].downcase.eql?('x')
      #end
    end
    
    def rule_create!
      roles.each do |role|
        mage_role = AdminRole.find_by_role(role)
        unless mage_role.nil?
          mage_rule = AdminRule.find(:first, :conditions => {:role_id => mage_role.id, :resource_id => rule}) || AdminRule.new
          mage_rule.update_attributes(
            :role_id => mage_role.id, 
            :resource_id => rule, 
            :privileges => '', 
            :assert_id => 0, 
            :role_type => 'G', 
            :permission => 'allow')
        end
      end
    end
    
  end
end
