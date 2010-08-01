    ec2log "Configuration Nginx pour Magento"
  # Install exclusive
  ec2cmd "rm /etc/nginx/sites-enabled/*"
  ec2cmd "cp #{installConfDir}/#{nginxMagentoConf} #{magentoConf}"
  ec2cmd "ln -s #{magentoConf} /etc/nginx/sites-enabled/magento"
  ec2cmd "sed -i 's/<magentoPort>/#{magentoPort}/' #{magentoConf}"
  ec2cmd "sed -i 's/<magentoHost>/#{magentoHost}/' #{magentoConf}"
  ec2cmd "sed -i 's/<wwwRoot>/#{wwwRoot.gsub('/', '\/')}/' #{magentoConf}"
  ec2cmd "sed -i 's/<magentoCurrent>/#{magentoCurrent}/' #{magentoConf}"
  ec2cmd "/etc/init.d/nginx restart", NO_LOG
  ec2log "...configuration Nginx pour Magento terminee"