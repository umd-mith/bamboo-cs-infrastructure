require 'utukku/engine'
require 'utukku/client'

class Utukku::Agent

  require 'utukku/agent/connection'
  require 'utukku/agent/flow'

  def initialize(url = nil, &block)
    @url = url
    @flows = { }
    @events = { }
    @setup = false
    @exported_namespaces = [ ]
    @needs_client = false

    if block
      self.instance_eval &block
      self.run
      self.close
    end
  end

  def close
    @connection.close if @connection
  end

  def url(u)
    @url = u
  end

  def needs_client
    @needs_client = true
  end

  def export_namespace(ns)
    @exported_namespaces.push(ns)
  end

  def event(nom, &block)
    @events[nom] = block
  end

  def setup
    if @needs_client
      @client = Utukku::Client.new(@url)
      @client.interactive = true
      @client.setup
    end

    @events['flow.create'] ||= proc { |klass, data, id|
      @flows[id] = Utukku::Agent::Flow.new(self, data, id)
      @flows[id].start
    };

    @events['flow.provide'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].provide(data)
      end
    };

    @events['flow.provided'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].provided(data)
        @flows.delete(id) if @flows[id].provided?
      end
    };

    @events['flow.close'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].finish()
        @flows.delete(id)
      end
    };

    @connection = Utukku::Agent::Connection.new(@url)
    @connection.namespaces = @exported_namespaces

    @setup = true
  end

  def response(klass, data, id)
    if @connection
      @connection.send([ klass, id, data ])
    else
      @queue.push([ klass, id, data ])
    end
  end

  def clear_queue
    if @connection
      @queue.each { |r| @connection.response(r) }
      @queue = [ ]
    end
  end

  def run
    self.setup unless @setup
    @connection.connect do |msg|
      if @events[msg[0]]
        @events[msg[0]].call(msg[0], msg[2], msg[1])
      end
    end
  end

  def close
    if @client
     @client.close
    end
    @connection.close
  end
end
