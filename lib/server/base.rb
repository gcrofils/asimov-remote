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
  
  def method_missing(meth, *args, &block)
    #puts "#{self.inspect} from method missing"
    if args.size == 0
      self[meth.to_s] || self[meth.to_sym]
    end
  end
  
  def type
    self['type']
  end

  def has?(key)
    self[key] && !self[key].to_s.empty?
  end

  def does_not_have?(key)
    self[key].nil? || self[key].to_s.empty?
  end
end


module ActiveSupport::Inflector
  # does the opposite of humanize ... mostly.
  # Basically does a space-substituting .underscore
  def dehumanize(the_string)
    result = the_string.to_s.dup
    result.downcase.gsub(/ +/,'_')
  end
end

class String
  def dehumanize
    ActiveSupport::Inflector.dehumanize(self)
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
      if Settings.configuration
        default_settings.merge! Settings.configuration[self.class.name.downcase].flatten!
      else
        default_settings
      end
    end
    
  end
end