

  require 'server'
  require 'settings'
  mysql_root_password = ARGV.shift
  Mysql.new.create_database mysql_root_password