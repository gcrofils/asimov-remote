require 'lipsum/lib/lipsum'
    
module Kernel
  def logger
    ASIMOV_DEFAULT_LOGGER
  end
end

class FalseClass
  def checked?
    false
  end
end

class TrueClass
  def checked?
    true
  end
end

class String
  def checked?
    match(/(true|t|yes|y|1|x)$/i) != nil
  end
end

class NilClass
  def checked?
    false
  end
  def lipsum
    nil
  end
end

class String

  def lipsum
    self.gsub(/^!lipsum\(([0-9]+)\.\.([0-9]+)\.(words|characters)\)$/){Lipsum.generate(:start_with_lipsum => false, $3.to_sym => $1.to_i + rand($2.to_i-$1.to_i))} unless self.nil?
  end
  
  def htmlentities
    {
      'â' => '&#226;',
      'à' => '&#224;',
      'ä' => '&#228;',
      'ç' => '&#231;',
      'é' => '&#233;', 
      'è' => '&#232;',
      'ê' => '&#234;',
      'ë' => '&#235;',
      'ö' => '&#246;',
      'ô' => '&#244;',
      'û' => '&#251;',
      'ü' => '&#252;',
      'ù' => '&#249;',
      '’' => '&#39;',
      '\'' => '&#39;',
      '"' => '&#34;',
      '(c)' => '&#169;',
      '©' => '&#169;',
      '(R)' => '&#174;',
      '®' => '&#174;',
      '°' => '&#176;',
      ' ' => '&nbsp;',
      '…' => '&#8230;',
      '«' => '&#171;',
      '»' => '&#187;'
    }.each_pair{|character, htmlentity| self.gsub!(character, htmlentity)} unless self.nil?
    self
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