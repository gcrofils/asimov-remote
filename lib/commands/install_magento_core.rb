require 'server'
require 'settings'
Magento.new.install_core
puts "magento core"

#! /bin/sh
#
#php -f install.php -- --get_options
#
# Locales "en_US", "fr_FR"
# Timezones "America/Los_Angeles", "Europe/Paris"
# default_currency "USD", "EUR"
#

