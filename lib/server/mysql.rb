#CREATE DATABASE <database>  SET utf8 COLLATE utf8_bin;
#CREATE USER '<user>'@'localhost' IDENTIFIED BY '<password>';
#GRANT ALL PRIVILEGES on <database>.* to <user>@localhost IDENTIFIED BY '<password>';

require 'tempfile'

class Mysql
  
  def create_database mysql_root_password
    unless mysql_root_password.nil?
      conf = ActiveRecord::Base.configurations
      cmd = " CREATE DATABASE #{conf[:database]}  SET utf8 COLLATE utf8_bin;
            CREATE USER '#{conf[:username]}'@'localhost' IDENTIFIED BY '#{conf[:password]}';
            GRANT ALL PRIVILEGES on #{conf[:database]}.* to #{conf[:username]}@localhost IDENTIFIED BY '#{conf[:password]}'"
      tf = TempFile.new('mysql_')
      tf.puts cmd
      tf.flush
      system("mysql -hlocalhost -uroot -p#{mysql_root_password} < #{tf.path}")
    end
  end
  
  
end