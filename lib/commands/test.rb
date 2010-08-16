require 'server'
require 'settings'
require 'magento-themes/init'
require 'theme'
require 'block'
require 'page'
require 'magento/magento_base'

client = ARGV.shift
magetheme = client

puts CmsBlock.all.inspect

#puts "start TESTS"
#Magento.new.load_catalogue

#les_instants_de_vie
#les-instants-de-vie

#m = Mage::Product.new
#m.send("category_add".to_sym, "toto")
#magento = Magento.new

#Mage::ProductNewAttribute.find(:all)[0..2].each do |p|
#  p.create!
#end
#puts Mage::ProductNewAttribute.headers


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

#client = Savon::Client.new('http://delhaye.milizone.com/api/v2_soap?wsdl=1')
#response = client.login { |soap| soap.body = { :username => 'admin', :api_key => 'secret09' } }
#unless response.http_error?
#  pp response.to_hash[:login_response][:login_return]
#end