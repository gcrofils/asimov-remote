require 'lipsum/lib/lipsum'
    
module Kernel
  def logger
    ASIMOV_DEFAULT_LOGGER
  end
end

class String

  def lipsum
    self.gsub(/^!lipsum\(([0-9]+)\.\.([0-9]+)\.(words|characters)\)$/){Lipsum.generate(:start_with_lipsum => false, $3.to_sym => $1.to_i + rand($2.to_i-$1.to_i))} unless self.nil?
  end
end


module ActiveSupport
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s

      level = {
        0 => "DEBUG",
        1 => "INFO",
        2 => "WARN",
        3 => "ERROR",
        4 => "FATAL"
      }[severity] || "U"

      message = "[%s: %s #%d] %s" % [level,
                                     Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                                     $$,
                                     message]

      message = "#{message}\n" unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
  end
end