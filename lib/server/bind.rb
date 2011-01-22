
class Bind < Server::Base

  def default_settings
  {
          :bind_conf_path => "/chroot/",
  }
  end

  def setup
     FileUtils.cp_r File.join(ASIMOV_ROOT, 'etc', 'named'), configuration[:bind_conf_path]
     %w[perms start].each do |ext|
       FileUtils.mv File.join(configuration[:bind_conf_path], 'named', "named.#{ext}"), File.join(configuration[:bind_conf_path], "named.#{ext}")
     end
  end
end