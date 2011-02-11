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
  end

  def next
    @frames.shift
  end

  def send(data)
    @client.send(data.to_json)
  end

  def close(immediate = false)
    @reader.kill if @reader && immediate
    @reader.join if @reader
  end

    end
  end
end
