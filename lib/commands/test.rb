require 'server'
require 'settings'

puts "start TESTS"
Magento.new.load_catalogue

#les_instants_de_vie
#les-instants-de-vie

#magento = Magento.new
#api = Mage::Api.new

#c = Mage::Category.new
#c.api = api
#pp c.api.categories

#Mage::Category.find(:all).each do |c|
#  c.api = api
#  puts "#{c.parent_url_key} #{c.url_key}"
#  puts "WARN #{c.parent_url_key} not exists" unless c.parent_exist?
 # puts "INFO #{c.url_key} exists" unless c.not_exist?
#  puts "====="
#end

#    Mage::Category.find(:all).each do |c|
#      c.api = api
#      c.create!
#    end
#    pp api.categories