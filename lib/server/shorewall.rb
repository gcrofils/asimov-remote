class Shorewall < Server::Base

  def default_settings
  {
          :shorewall_conf_path 		=> "/etc/",
	  :shorewall_start_filename	=> "/etc/default/shorewall"
  }
  end

  def setup
     FileUtils.cp_r File.join(ASIMOV_ROOT, 'etc', 'shorewall'), configuration[:shorewall_conf_path]
     system ("echo 'startup=1' > #{configuration[:shorewall_start_filename]}")
     system ("echo 'OPTIONS=\"\"' >> #{configuration[:shorewall_start_filename]}")
  end
end
