require 'web_socket'
require 'json'

module Utukku
  class Client
    class Connection

  attr_accessor :url, :done

  def initialize(url = nil)
    @url = url
    @frames = [ ]
    @should_close = false
    @done = false
  end

  def connect(&block)
    @client = WebSocket.new(@url)
    @reader = Thread.new() do
      while data = @client.receive()
        if block
          yield JSON.parse(data)
        else
          @frames.push JSON.parse(data)
        end
        break if @done 
      end
    end
    @reader.run
  end

  def next
    @frames.shift
  end

  def send(data)
puts "out: #{data.to_json}"
    @client.send(data.to_json)
  end

  def wake
    @reader.run if @reader.status == 'sleep'
  end

  def close(immediate = false)
    @reader.kill if @reader && (immediate || @done)
    @reader.join if @reader
  end

    end
  end
end
