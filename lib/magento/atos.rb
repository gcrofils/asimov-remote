require 'magento/base'

module Mage
  class Atos
    
    attr_accessor :configuration
    
    def initialize(config)
      @configuration = config
    end
    
    def install
      make_atos_dir
      copy_config_files
      chmod
    end
    
private
    
    def make_atos_dir
      FileUtils.mkdir_p target_path
    end
    
    def copy_config_files
      Dir[File.join(source_path, '*')].each do |file|
        FileUtils.cp file, File.join(target_path, File.basename(file))
      end
    end
    
    def chmod
      FileUtils.chmod 0755, File.join(target_path, 'request')
      FileUtils.chmod 0755, File.join(target_path, 'response')
    end
    
    def source_path
      File.join(ASIMOV_ROOT, 'etc', 'atos')
    end
    
    def target_path 
      File.join(configuration.www_root_path, 'lib', 'atos')
    end
  end
end