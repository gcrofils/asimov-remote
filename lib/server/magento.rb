require 'magento/magento_base'
require 'magento/api'
require 'magento/rule'
require 'magento/user'
require 'magento/category'
require 'pp'

class Magento < Server::Base
  
  attr_accessor :api

  def default_settings
  {
          :www_root_path    => '',
          :locale           => 'fr_FR',
          :timezone         => 'Europe/Paris',
          :currency         => 'EUR',
          :admin_frontname  => 'admin',
          :domain           => '',
          :spreadsheet_rules => '',
          :spreadsheet_users => '',
          :spreadsheet_categories => '',
          :modules          => Array.new,
          :www_user         => 'www',
          :www_group        => 'www'
  }
  end

  def initialize
  super
  initialize_user
  end

  def initialize_user
    Mage::User.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_users}&hl=fr&single=true&output=csv"
    Mage::Rule.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_rules}&hl=fr&single=true&output=csv"
    Mage::Category.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_categories}&hl=fr&single=true&output=csv"
  end

  def users
    @users ||= Mage::User.all
  end
  
  def install
    install_core
    install_modules
    cleaning
  end

  def install_core
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
      --admin_firstname \"#{admin.first_name}\"
      --admin_lastname \"#{admin.last_name}\"
      --admin_email \"#{admin.email}\"
      --admin_username \"#{admin.user_name}\"
      --admin_password \"#{admin.password}\"".gsub("\n", " \\\n")
      
      system cmd
      logger.info 'install magento OK'
      FileUtils.chown_R c.www_user, c.www_group, c.www_root_path

  end
  
  def install_modules
    if c.modules.size > 0
       cmd = "cd #{c.www_root_path} \n"
       cmd += "./pear mage-setup . \n"
       c.modules.each {|m| cmd += "./pear install #{m} \n"}
       cmd += "./pear clear-cache \n"
       system cmd
   end
 end
 
 def cleaning
   FileUtils.rm_rf File.join(c.www_root_path, 'var', 'cache')
   FileUtils.rm_rf File.join(c.www_root_path, 'var', 'session')
 end
  
  def load_data
    Mage::User.find(:all).each{|u| u.role_create!}
    Mage::User.find(:all).each{|u| u.user_create!}
    Mage::Rule.find(:all).each{|r| r.rule_create!}
    api = Mage::Api.new
    api.create_role
    api.create_user :user_name => admin.user_name, :password => admin.password
    load_catalogue
  end
  
  def load_catalogue
    api = Mage::Api.new
    Mage::Category.find(:all).each do |c|
      c.api = api
      c.create!
    end
    pp api.categories
  end
  
  private
  
  def c
    configuration
  end
  
  def db
    ActiveRecord::Base.configurations
  end
  
  def admin
    @admin ||= Mage::User.find(:admin).first
  end
end