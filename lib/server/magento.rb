require 'magento/magento_base'
require 'magento/api'
require 'magento/rule'
require 'magento/user'
require 'magento/category'
require 'magento/product'
require 'magento/product_new_attribute'
require 'magento/image'
require 'magento/atos'
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
          :spreadsheet_products => '',
          :spreadsheet_products_new_attributes => '',
          :modules          => Array.new,
          :www_user         => 'www',
          :www_group        => 'www'
  }
  end

  def initialize
  super
  initialize_uri
  end

  def initialize_uri
    Mage::User.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_users}&hl=fr&single=true&output=csv"
    Mage::Rule.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_rules}&hl=fr&single=true&output=csv"
    Mage::Category.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_categories}&hl=fr&single=true&output=csv"
    Mage::Product.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_products}&hl=fr&single=true&output=csv"
    Mage::ProductNewAttribute.uri = "http://spreadsheets.google.com/pub?#{c.spreadsheet_products_new_attributes}&hl=fr&single=true&output=csv"
    Mage::Image.uri = "http://picasaweb.google.com/data/feed/base/user/#{c.picasa}?alt=rss&kind=photo&hl=en_US"
  end

  def users
    @users ||= Mage::User.all
  end
  
  def install
    install_core
    install_modules
    install_atos
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
 
 def install_atos
   Mage::Atos.new(c).install
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
    logger.debug "******** START Loading catalog *********"
    begin
      load_catalogue api
      load_new_attributes api
    rescue Exception => e
      logger.error "Error during Catalog loading : #{e}"
    end
  end
  
  def load_catalogue(api)
    Mage::Category.find(:all).each do |c|
      c.api = api
      c.create! if c.not_exist?
    end
    Mage::Product.find(:all).each do |p|
      p.api = api
      p.upsert!
    end
  end
  
  def load_new_attributes(api)
    Mage::ProductNewAttribute.find(:all).each do |p|
      p.api = api
      p.create!
    end
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