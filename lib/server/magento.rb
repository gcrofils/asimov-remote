require 'magento/user'

class Magento < Server::Base

  def default_settings
  {
          :www_root_path    => '',
          :locale           => 'fr_FR',
          :timezone         => 'Europe/Paris',
          :currency         => 'EUR',
          :admin_frontname  => 'admin',
          :domain           => '',
          :spreadsheet_roles => '',
          :spreadsheet_users => '',
          :modules          => Array.new
  }
  end

  def initialize_user
    Mage::User.uri = 'http://spreadsheets.google.com/pub?key=0AlfH23zMTsE0dE5wR25nU2NjeGxXcXlvemM0M1NJbHc&hl=fr&single=true&gid=1&output=csv'
  end

  def users
    @users ||= Mage::User.all
  end

  def install_core
    initialize_user
    c = configuration
    db = ActiveRecord::Base.configurations
    users.each{|row| row.each {|col| puts col.dehumanize}}
    
    cmd = "php -f #{File.join(c.www_root_path, 'install.php')} --
      --license_agreement_accepted \"yes\"
      --locale \"#{c.locale}\"
      --timezone \"#{c.timezone}\"
      --default_currency \"#{c.currency}\"
      --db_host \"#{db.host}\"
      --db_name \"#{db.database}\"
      --db_user \"#{db.username}\"
      --db_pass \"#{db.password}\"
      --db_prefix \"\"
      --session_save \"files\"
      --admin_frontname \"#{c.admin_frontname}\"
      --url \"http://#{c.domain}/\"
      --skip_url_validation \"yes\"
      --use_rewrites \"yes\"
      --use_secure \"no\"
      --secure_base_url \"\"
      --use_secure_admin \"no\"
      --admin_firstname \"<admin_firstname>\"
      --admin_lastname \"<admin_lastname>\"
      --admin_email \"<admin_email>\"
      --admin_username \"<admin_username>\"
      --admin_password \"<admin_password>\""
     # puts cmd
  end
end