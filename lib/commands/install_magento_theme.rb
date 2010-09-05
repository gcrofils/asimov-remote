require 'magento-themes/init'

client = ARGV.shift
magetheme = ARGV.shift || client
mageroot = ARGV.shift || '/home/www/magento'

MageTheme::Theme.new(:client => client, :theme => magetheme, :root => mageroot).install