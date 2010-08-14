require 'magento-themes/init'

client = ARGV.shift
magetheme = client

MageTheme::Theme.new(:client => client, :theme => magetheme).install