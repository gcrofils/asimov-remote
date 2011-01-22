require 'server'
require 'server/magento'
require 'settings'
Magento.new.load_data

puts "load_magento_data"