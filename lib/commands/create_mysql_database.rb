

  require 'server'
  require 'server/magento'
  require 'settings'
  mysql_root_password = ARGV.shift
  Server::Mysql.new.create_database mysql_root_password