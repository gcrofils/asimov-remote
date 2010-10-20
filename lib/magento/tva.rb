require 'magento/base'

module Mage
  class Tva
    
    attr_accessor :configuration, :tva_code
    
    def initialize(config)
      @configuration = config
    end
    
    def setup
      delete_all_tax_calculations
      add_tax_calculation :rate_code => 'France-normal', :rule_code => 'TVA Normal', :product_class_name => 'Taux Normal', :customer_class_name => 'Retail Customer'
    end
    
private
    
    def tax_calculation_rule(options = {})
      code      = options[:rule_code]
      TaxCalculationRule.find_by_code(code) || TaxCalculationRule.create(:code => code, :position=>1, :priority=>1)
    end
    
    def tax_calculation_rate(options = {})
      country   = options[:country]  || 'FR'
      region    = options[:region]   || 0
      code      = options[:rate_code]
      rate      = options[:rate]     || 19.6
      postcode  = options[:country]  || '*'
      TaxCalculationRate.find_by_code(code) || TaxCalculationRate.create(:tax_country_id => country, :tax_region_id => region, :tax_postcode => postcode, :code => code, :rate => rate)
    end
    
    def product_tax_class(options = {})
      name      = options[:product_class_name]
      TaxClass.find(:first, :name => name) || TaxClass.create(:class_name => name, :class_type => 'CUSTOMER')
    end
    
    def customer_tax_class(name)
      name      = options[:customer_class_name]
      TaxClass.find(:first, :name => name) || TaxClass.create(:class_name => name, :class_type => 'PRODUCT')
    end
    
    def delete_all_tax_calculations
      TaxCalculation.delete_all
    end
    
    def add_tax_calculation(options = {})
      TaxCalculation.create(
        :tax_calculation_rate_id => tax_calculation_rate(options).id,
        :tax_calculation_rule => tax_calculation_rule(options).id,
        :product_tax_class_id => product_tax_class(options).id,
        :customer_tax_class_id => customer_tax_class(options).id
        )
    end
  end
end

