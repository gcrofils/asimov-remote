require 'magento/base'

module Mage
  class Rule < Mage::Base
    
    attr_accessor :rule
    attr_accessor :role
    attr_accessor :rule_value
    cattr_accessor :uri
    
    def method_missing(meth, *args, &block)
      #if meth.to_s[0..0].eql?('*')
        self.role = meth.to_s.gsub('=','').gsub('*','')
        self.rule_value = args[0]
      #end
    end
    
    def rule_create!
      mage_role = AdminRole.find_mage_role(role)
      unless mage_role.nil?
        mage_rule = AdminRule.find(:first, :conditions => {:role_id => mage_role.id, :resource_id => rule})
        mage_rule.update_attributes(
          :role_id => mage_role.id, 
          :resource_id => rule, 
          :privileges => '', 
          :assert_id => 0, 
          :role_type => 'G', 
          :permission => (rule_value.downcase.eql?('x') ? 'allow' : 'deny')
          ) unless rule_value.eql?('-')
        mage_rule.destroy if rule_value.eql?('-')
      end
    end
    
  end
end
