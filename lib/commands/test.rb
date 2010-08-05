require 'server'
require 'settings'

puts "start TESTS"
options = {:parent_id => 2, :name => 'tuti', 'is_active' => 1, 'default_sort_by' => 'name', 'available_sort_by' => {'ArrayOfString' => 'name'}}
Mage::Api.new.create_category(options)