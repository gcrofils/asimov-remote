module Server
  class Nginx < Server::Base
    
    def initialize
      @default_settings = {
          :site_enabled_path => "/etc/nginx/sites-enabled",
          :site_handler => '',
          :site_port => '80',
          :site_host => '',
          :site_root_path => ''
      }
    end
  end
end