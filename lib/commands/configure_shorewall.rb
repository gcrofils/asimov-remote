
require 'server'
require 'server/shorewall'
require 'settings'

puts "Configuration Shorewall..."
Shorewall.new.setup
system('service shorewall restart')
puts "... configuration Shorewall terminée."
