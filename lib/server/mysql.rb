#CREATE DATABASE <database>  SET utf8 COLLATE utf8_bin;
#CREATE USER '<user>'@'localhost' IDENTIFIED BY '<password>';
#GRANT ALL PRIVILEGES on <database>.* to <user>@localhost IDENTIFIED BY '<password>';

require 'tempfile'

module Server

class Mysql
  
  def create_database mysql_root_password
    unless mysql_root_password.nil?
      conf = ActiveRecord::Base.configurations
      cmd = " CREATE DATABASE IF NOT EXISTS #{conf[:database]} CHARACTER SET utf8 COLLATE utf8_bin;
            GRANT ALL PRIVILEGES on #{conf[:database]}.* to #{conf[:username]}@localhost IDENTIFIED BY '#{conf[:password]}'"
      tf = Tempfile.new('mysql_')
      tf.puts cmd
      tf.flush
      system("mysql -f -hlocalhost -uroot -p#{mysql_root_password} < #{tf.path}")
    end
  end

  
end
end