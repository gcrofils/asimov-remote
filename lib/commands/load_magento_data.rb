require 'server'
require 'settings'
#Magento.new.load_data
options = {:parent_id => 2, :name => 'tuti', 'is_active' => 1, 'default_sort_by' => 'name', 'available_sort_by' => {'ArrayOfString' => 'name'}}
Mage::Api.new.create_category(options)

puts "load_magento_data"