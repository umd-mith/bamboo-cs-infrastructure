require 'rest_client'

class Utukku::Engine::RestClientIterator < Utukku::Engine::Iterator
  def initialize(config, &block)
    @options = config
    @processor = block
  end

  def start
    req = RestClient::Request.new({
      :method => @options[:method].to_s.upcase,
      :url => @options[:url],
      :params => @options[:params]
    })
puts YAML::dump(req)
    it = nil
    req.execute { |r| 
      puts "response: #{YAML::dump(r)}"
      it = @processor.call(r) 
    }
    if it.is_a?(Utukku::Engine::Iterator)
      it.start
    else
      Utukku::Engine::ConstantIterator.new(it).start
    end
  end

  def build_async(callbacks)
puts "build_async..."
    proc {
      req = RestClient::Request.new({
        :method => @options[:method].to_s.uppercase,
        :url => @options[:url],
        :params => @options[:params]
      })
puts YAML::dump(req)
      it = nil
      req.execute { |r| 
        puts "response: #{YAML::dump(r)}"
        it = @processor.call(r) 
      }

      if it.is_a?(Utukku::Engine::Iterator)
        it.async(callbacks)
      else
        callbacks[:next].call(it)
        callbacks[:done].call()
      end
    }
  end
end
