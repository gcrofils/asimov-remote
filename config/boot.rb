ASIMOV_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')) unless defined?(ASIMOV_ROOT)

module Asimov
  class << self
    def boot!
      unless booted?
        Boot.new.run
      end
    end

    def booted?
      defined? Asimov::Initializer
    end
  end
  
  class Boot
    def run
      require "#{ASIMOV_ROOT}/config/initializer"
      Asimov::Initializer.run
    end
  end
end

Asimov.boot!
