
require 'server'
require 'settings'

puts "Configuration BIND..."
Bind.new.setup
system('/etc/init.d/named restart')
puts "... configuration BIND terminée."