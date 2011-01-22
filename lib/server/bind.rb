
class Bind < Server::Base

  def default_settings
  {
          :bind_conf_path => "/chroot/",
  }
  end

  def setup
     FileUtils.cp_r File.join(ASIMOV_ROOT, 'etc', 'named'), configuration[:bind_conf_path]
     FileUtils.mv File.join(configuration[:bind_conf_path], 'named', 'named.*'), configuration[:bind_conf_path]
  end
end