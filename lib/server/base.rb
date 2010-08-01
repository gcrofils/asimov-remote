class Hash
  def flatten!
    self
  end
end

module Server
  class Base
    
    attr_accessor :configuration
    attr_accessor :default_settings
    
    def initialize
      @configuration = Settings.configuration[self.class.name.downcase].flatten! || {}
    end
    
    def load_configuration
      configuration = default_settings.merge(configuration)
    end
    
  end
end