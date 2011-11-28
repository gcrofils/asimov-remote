
class Bind < Server::Base

  def default_settings
  {
          :bind_conf_path => "/chroot/",
  }
  end

  def setup
     FileUtils.cp_r File.join(ASIMOV_ROOT, 'etc', 'named'), configuration[:bind_conf_path]
     FileUtils.cp File.join(ASIMOV_ROOT, 'etc', 'cron', 'updateGeoIp'), '/etc/cron.monthly/'
     %w[perms start].each do |ext|
       FileUtils.mv File.join(configuration[:bind_conf_path], 'named', "named.#{ext}"), File.join(configuration[:bind_conf_path], "named.#{ext}")
     end
     FileUtils.ln_sf File.join(configuration[:bind_conf_path], 'named', 'etc', 'rndc.conf'), '/usr/local/bind9/etc/rndc.conf'
     FileUtils.ln_sf File.join(configuration[:bind_conf_path], 'named', 'etc', 'rndc.conf'), '/etc/rndc.conf'
     FileUtils.ln_sf "/chroot/named/named", "/etc/init.d/named"
     geoIP = File.join('/', 'chroot', 'named', 'usr', 'local', 'share', 'GeoIP')
     FileUtils.mkdir_p geoIP
     system ('sh /etc/cron.monthly/updateGeoIp')
     FileUtils.cp_f '/usr/local/share/GeoIP/GeoIP.dat', File.join(geoIP, 'GeoIP.dat')
     system ('sh /chroot/named.perms')
  end
end
