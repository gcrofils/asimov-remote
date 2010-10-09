require 'server'
require 'settings'
api = Mage::Api.new 
Magento.new.load_images api
puts "Fin install Magento"