require 'rubygems'
require 'active_record'


module Lipsum
  
    class UnsupportedType < StandardError; end
    class MustBePositive < StandardError; end
  
    class Base
      
      WORDS   = %w[ a ac accumsan adipiscing aenean aliquam aliquet amet ante arcu at auctor augue bibendum blandit commodo condimentum congue consectetuer consequat convallis cras curabitur cursus dapibus diam dictum dignissim dolor donec dui duis egestas eget eleifend elementum elit enim erat eros est et etiam eu euismod facilisi facilisis fames faucibus felis fermentum feugiat fringilla fusce gravida habitant hendrerit iaculis id imperdiet in integer interdum ipsum justo lacinia lacus laoreet lectus leo libero ligula lobortis lorem luctus maecenas magna malesuada massa mattis mauris metus mi molestie mollis morbi nam nec neque netus nibh nisi nisl non nonummy nulla nullam nunc odio orci ornare pede pellentesque pharetra phasellus placerat porta porttitor posuere praesent pretium proin pulvinar purus quam quis quisque rhoncus risus rutrum sagittis sapien scelerisque sed sem semper senectus sit sodales sollicitudin suscipit suspendisse tellus tempor tempus tincidunt tortor tristique turpis ullamcorper ultrices ultricies urna ut varius vehicula vel velit venenatis vestibulum vitae vivamus viverra volutpat vulputate ]
      LIPSUM  = %w[ lorem ipsum dolor sit amet ]
      CONSECTETUR = %w[ consectetur adipiscing elit ]
      TYPES   = [:paragraphs, :words, :characters]
      
      MIN_NUMBER_OF_PARAGRAPHS = 1
      MIN_NUMBER_OF_WORDS = 5
      MIN_NUMBER_OF_CHARACTER = 27
      
        
        def initialize(options = {})
          define_options(options)
        end
      
        def generate(options = nil)
          define_options(options) unless options.nil?
          finalize
        end
        
        def finalize
          characters
        end
        
        def define_options(opts)
          @options ||= {
            :start_with_lipsum => true,
            :paragraphs => MIN_NUMBER_OF_PARAGRAPHS,
            :words => MIN_NUMBER_OF_WORDS,
            :characters => MIN_NUMBER_OF_CHARACTER
          }
          @options = @options.merge(opts)
          check_options
        end
        
        def check_options
          must_be_positive
        end
        
        def must_be_positive
          TYPES.each{|t| raise MustBePositive if options[t]< 1}
        end
        
        def characters
          text = ''
          buffer = ''
          buffer = LIPSUM.dup.join(' ') if @options[:start_with_lipsum]
          buffer = "#{buffer}, #{CONSECTETUR.dup.join(' ')}" if @options[:characters] >= LIPSUM.dup.join(' ').length + CONSECTETUR.dup.join(' ').length
          while (text.length + buffer.length) < (@options[:characters])
            buffer = "#{buffer} #{word(@options[:characters] - text.length - buffer.length - ((@options[:characters] - text.length - buffer.length).eql?(1) ? 0 : 2))}"
            puts "BUFFER #{buffer.length} #{buffer}<"
            unless (buffer.length + text.length) > (@options[:characters] - 10)
              if rand(100) < 15
                text += "#{buffer.strip.capitalize}. "
                buffer = ''
             elsif rand(100) < 8
                buffer += ','
              end
            end
            puts "TEXT #{text.length} #{text}<"
            puts "BUFFER #{buffer.length} #{buffer}<"
            puts "== #{buffer.length + text.length} < #{@options[:characters]} == "
          end
          text += "#{buffer.strip.capitalize}."
          text
        end
        
        def words
          text = ''
          buffer = ''
          nbwords = 0
          if @options[:start_with_lipsum]
            buffer = LIPSUM.dup.join(' ')
            nbwords = LIPSUM.size
          end
          if @options[:words] >= LIPSUM.size + CONSECTETUR.size
            buffer = "#{buffer}, #{CONSECTETUR.dup.join(' ')}"
            nbwords += CONSECTETUR.size
          end
          while nbwords < @options[:words]
            buffer = "#{buffer} #{word}"
            nbwords += 1
            unless nbwords.eql?(@options[:words])
              if rand(100) < 15
                text += "#{buffer.strip.capitalize}. "
                buffer = ''
              elsif rand(100) < 8
                buffer += ','
              end
            end
          end
          text += "#{buffer.strip.capitalize}."
          text
        end
        
        def min_word_size
          @min_word_size ||= WORDS.map{|w| w.length}.min
        end

        def max_word_size
          @max_word_size ||= WORDS.map{|w| w.length}.max
        end
        
        def word(length=0)
          puts "length #{length}"
          words = (length.eql?(0) or length > max_word_size)? WORDS : WORDS.select{|w| w.length.eql?(length)}
          words.shuffle.first
        end
        
      
    end

end