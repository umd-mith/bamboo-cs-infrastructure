require 'bamboo/engine'
require 'bamboo/agent/connection'
require 'bamboo/agent/flow'

module Bamboo
class Agent
  attr_accessor :url

  def initialize(url = nil)
    @url = url
    @flows = { }
    @events = { }
    @setup = false
    @exported_namespaces = [ ]
  end

  def close
    @connection.close if @connection
  end

  def export_namespace(ns)
    @exported_namespaces.push(ns)
  end

  def event(nom, &block)
    @events[nom] = block
  end

  def setup
    @events['flow.create'] ||= proc { |klass, data, id|
      @flows[id] = Bamboo::Agent::Flow.new(self, data, id)
      @flows[id].start
    };

    @events['flow.provide'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].provide(data['iterators'])
      end
    };

    @events['flow.provided'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].provided(data['iterators'])
      end
    };

    @events['flow.close'] ||= proc { |klass, data, id|
      if @flows[id]
        @flows[id].finish()
        @flows.delete(id)
      end
    };

    @events['flow.namespace.registered'] ||= proc { |klass, data, id|
    };

    @connection = Bamboo::Agent::Connection.new(@url)
    @connection.namespaces = @exported_namespaces

    @setup = true
  end

  def response(klass, data, id)
    if @connection
      @connection.response({ 'class' => klass, 'data' => data, 'id' => id })
    else
      @queue.push({ 'class' => klass, 'data' => data, 'id' => id })
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
      if @events[msg['class']]
        @events[msg['class']].call(msg['class'], msg['data'], msg['id'])
      end
    end
  end

  def close
    @connection.close
  end
end
end
