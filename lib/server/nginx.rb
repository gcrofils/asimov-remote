module Server
  class Nginx < Server::Base
    attr_accessor :sites_enabled_path
    attr_accessor :site_handler
    attr_accessor :site_port
    attr_accessor :site_host
    attr_accessor :site_www_root_path
    
    def initialize
      @sites_enabled_path = "/etc/nginx/sites-enabled"
    end
  end
end