require 'logger'
require 'set'
require 'pathname'
require 'yaml'
require 'rubygems'
gem 'activerecord', '=2.3.8'
require 'active_support'
require 'fileutils'

DEFAULT_ENV = 'development'  
ASIMOV_ENV = (ENV['ASIMOV_ENV'] || DEFAULT_ENV).dup unless defined?(ASIMOV_ENV)



module Asimov
  
   # The Configuration instance used to configure the Rails environment
  def self.configuration
    @@configuration
  end

  def self.configuration=(configuration)
    @@configuration = configuration
  end
  
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
      initialize_logger
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
      ActiveRecord::Base.configurations = configuration.database_configuration
      ActiveRecord::Base.establish_connection(configuration.database_configuration) unless configuration.database_configuration.nil?
      ActiveRecord::Base.logger = ASIMOV_DEFAULT_LOGGER
    end
    
    def initialize_settings
      require 'settings'
      Settings.configuration = configuration.settings_configuration unless configuration.settings_configuration.nil?
    end
    
    def initialize_logger
      # if the environment has explicitly defined a logger, use it
      return if defined?(ASIMOV_DEFAULT_LOGGER)
      
      unless logger = configuration.logger
        begin
          logger = ActiveSupport::BufferedLogger.new(configuration.log_path)
          logger.level = ActiveSupport::BufferedLogger.const_get(configuration.log_level.to_s.upcase)
          if configuration.environment == "production"
            #logger.auto_flushing = false
            #logger.set_non_blocking_io
          end
        rescue StandardError => e
            logger = ActiveSupport::BufferedLogger.new(STDERR)
            logger.level = ActiveSupport::BufferedLogger::WARN
            logger.warn(
              "Asimov Error: Unable to access log file. Please ensure that #{configuration.log_path} exists and is chmod 0666. " +
              "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed.\n" + e
             )
        end
      end

      #silence_warnings { Object.const_set "ASIMOV_DEFAULT_LOGGER", logger }
      Object.const_set "ASIMOV_DEFAULT_LOGGER", logger
    end
    
  end
  
  class Configuration
    attr_accessor :load_paths
    attr_accessor :database_configuration_file
    attr_accessor :settings_configuration_file
    attr_accessor :log_level
    attr_accessor :log_path
    attr_accessor :logger
    
    def initialize
      self.load_paths                 = default_load_paths
      self.database_configuration_file  = default_database_configuration_file
      self.settings_configuration_file  = default_settings_configuration_file
      self.log_path                   = default_log_path
      self.log_level                  = default_log_level
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
    
    def default_log_path
      File.join(root_path, 'log', "#{environment}.log")
    end

    def default_log_level
      environment == 'production' ? :info : :debug
    end
    
  end
  
end
  
