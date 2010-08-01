require 'ftools'
require 'fileutils'

class Hash

  def flatten!(obj = self, stack = [], ret = {})
    case obj
      when Hash
        obj.each do |k,v|
          stack.push k
          flatten!(v, stack, ret)
          stack.pop
        end
      else
        ret[stack.join('_').to_sym] = obj
    end
    ret
  end
end



module Server
  class Base
    
    def configuration
      @configuration ||= load_configuration
    end
    
    def default_settings
      {}
    end
    
    def load_configuration
      default_settings.merge! Settings.configuration[self.class.name.downcase].flatten!
    end
    
  end
end