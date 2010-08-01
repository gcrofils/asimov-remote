
  require 'server'
  require 'settings'
  
  puts "Configuration NGINX..."
  Nginx.new.setup
  system('/etc/init.d/nginx restart')
  puts "... configuration NGINX terminée."