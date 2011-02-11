require 'utukku/client/connection'
require 'utukku/engine'
require 'utukku/engine/tag_lib'
require 'utukku/engine/tag_lib/registry'
require 'utukku/engine/tag_lib/remote'
require 'uuid'

module Utukku
end

class Utukku::Client

  attr_accessor :url

  def initialize(url = nil, &block)
    @url = url

    @flows = { }
    @uuid = UUID.new

    @connection = Utukku::Client::Connection.new(@url)

    if block
      self.setup
      yield self
      self.manage_flow_lock
      self.close
    end
  end

  def close
    @connection.close if @connection
  end

  def done
    @connection.done = true
  end

  def setup
    @connection.connect do |msg|
      if  msg['class'] =~ /^flow\./ 
        self.flow(msg)
      end
    end
  end

  def register_flow(flow)
    @flows[flow.mid] = flow
    self.manage_flow_lock
  end

  def manage_flow_lock
    @connection.done = @flows.empty?
  end

  def deregister_flow(flow)
    @flows.delete(flow.mid)
    self.manage_flow_lock
  end

  def flow(msg)
    case msg['class']
      when 'flow.namespaces.registered'
        msg['data'].keys.each { |ns|
          if Utukku::Engine::TagLib::Registry.instance.handler(ns).nil?
            h = Utukku::Engine::TagLib::Remote.new(ns, msg['data'][ns])
            h.client = self
            Utukku::Engine::TagLib::Registry.instance.handler(ns, h)
          end
        }
      when 'flow.produce'
        flow = @flows[msg['id']]
        if !flow.nil?
          flow.message(msg['class'], msg['data'])
        end
      when 'flow.produced'
        flow = @flows[msg['id']]
        if !flow.nil?
          flow.message(msg['class'], msg['data'])
        end
    end
  end

  def request(klass, data, mid = nil)
    mid = @uuid.generate if mid.nil?
    if @connection.nil?
      @queue ||= [ ]
      @queue += [ { 'id' => mid, 'class' => klass, 'data' => data } ]
    else
      @connection.send({
        'id' => mid,
        'class' => klass,
        'data' => data
      })
    end
    mid
  end

  def clear_queue
    if !@connection.nil?
      @queue.each { |q| self.request(q['class'], q['data'], q['id']) }
    end
  end

  ## convenience method for calling functions
  def function(ns, nom, args, callbacks)
    handler = Utukku::Engine::TagLib::Registry.instance.handler(ns)
    if handler.nil?
      callbacks[:done].call()
    else
      iterator = handler.function_to_iterator(nom, args)
      iterator.async(callbacks)
    end
  end
end
