
class Bind < Server::Base

  def default_settings
  {
          :bind_conf_path => "/usr/local/bind9/etc/",
          :bind_conf_template => 'named.conf'
  }
  end

  def setup
     FileUtils.cp File.join(ASIMOV_ROOT, 'etc', configuration[:bind_conf_template]), configuration[:bind_conf_path]
     FileUtils.cp_r File.join(ASIMOV_ROOT, 'etc', 'namedb'), configuration[:bind_conf_path]
     FileUtils.ln_s File.join(ASIMOV_ROOT, 'etc', 'namedb'), '/etc/namedb'
  end
end