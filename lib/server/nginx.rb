

class Nginx < Server::Base

  def default_settings
  {
          :sites_enabled_path => "/etc/nginx/sites-enabled",
          :sites_available_path => "/etc/nginx/sites-available",
          :site_handler => '',
          :site_port => '80',
          :site_host => '',
          :site_www_root_path => '',
          :nginx_conf_template => 'nginx-phpfm.conf'
  }
  end

  def setup
     conf = File.new(File.join(ASIMOV_ROOT, 'etc', configuration[:nginx_conf_template])).read
     %w[ site_handler site_port site_host site_www_root_path ].each {|option| conf = conf.gsub("<#{option}>", configuration[option.to_sym].to_s)}
     nginx_conf_file = File.join(configuration[:sites_available_path], configuration[:site_handler])
     File.open(nginx_conf_file, 'w') {|f| f.write(conf) }
     FileUtils.rm Dir.glob(File.join(configuration[:sites_enabled_path], '*'))
     FileUtils.ln_s nginx_conf_file, File.join(configuration[:sites_enabled_path], configuration[:site_handler])
  end
end