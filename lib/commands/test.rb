require 'server'
require 'settings'

#puts "start TESTS"
#Magento.new.load_catalogue

#les_instants_de_vie
#les-instants-de-vie

magento = Magento.new
pp Mage::Api.new.products

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