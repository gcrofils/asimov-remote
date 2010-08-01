require 'logger'
require 'set'
require 'pathname'
require 'yaml'
require 'rubygems'
require 'active_record'

DEFAULT_ENV = 'development'  
ASIMOV_ENV = (ENV['ASIMOV_ENV'] || DEFAULT_ENV).dup unless defined?(ASIMOV_ENV)



module Asimov
  class Initializer
    attr_reader :configuration
    
    def self.run(command = :process, configuration = Configuration.new)
      yield configuration if block_given?
      initializer = new configuration
      initializer.send(command)
      initializer
    end
    
    def initialize(configuration)
      @configuration = configuration
    end
    
    def process
      set_load_path
      initialize_database
      initialize_settings
    end
    
    def set_load_path
      configuration.load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) }
      $LOAD_PATH.uniq!
    end
    
    def initialize_database
      require 'rubygems'
      require 'active_record'
      ActiveRecord::Base.establish_connection(configuration.database_configuration) unless configuration.database_configuration.nil?
    end
    
    def initialize_settings
      require 'settings'
      Settings.configuration = configuration.settings_configuration unless configuration.settings_configuration.nil?
    end
    

    
  end
  
  class Configuration
    attr_accessor :load_paths
    attr_accessor :database_configuration_file
    attr_accessor :settings_configuration_file
    
    def initialize
      @load_paths                   = default_load_paths
      @database_configuration_file  = default_database_configuration_file
      @settings_configuration_file  = default_settings_configuration_file
    end
    
    def environment
      ::ASIMOV_ENV
    end
    
    def database_configuration
      require 'erb'
      YAML::load(ERB.new(IO.read(database_configuration_file)).result) if File.exist?(database_configuration_file)
    end
    
    def settings_configuration
      require 'erb'
      YAML::load(ERB.new(IO.read(settings_configuration_file)).result) if File.exist?(settings_configuration_file)
    end

    
    private
    
    def root_path
       ::ASIMOV_ROOT
    end
    
    def default_load_paths
      paths = Array.new
      paths.concat %w(
        app/models
        app/apis
        config
        lib
        vendor
        ).map { |dir| "#{root_path}/#{dir}" }.select { |dir| File.directory?(dir) }
    end
    
    def default_database_configuration_file
      File.join(root_path, 'config', 'database.yml')
    end
    
    def default_settings_configuration_file
      File.join(root_path, 'config', 'settings.yml')
    end
    
  end
  
end
  
