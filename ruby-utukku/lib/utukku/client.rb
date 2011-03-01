require 'utukku/client/connection'
require 'utukku/engine'
require 'utukku/engine/tag_lib'
require 'utukku/engine/tag_lib/registry'
require 'utukku/engine/tag_lib/remote'
require 'uuid'

module Utukku
end

class Utukku::Client

  attr_accessor :url, :interactive

  def initialize(url = nil, &block)
    @url = url

    @flows = { }
    @uuid = UUID.new

    @request_id = 0
    @interactive = false

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
      msg = { 'class' => msg[0],
              'id' => msg[1],
              'data' => msg[2],
            }
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
    @connection.done = @flows.empty? && !@interactive
  end

  def deregister_flow(flow)
    @flows.delete(flow.mid)
    self.manage_flow_lock
  end

  def flow(msg)
    case msg['class']
      when 'flow.namespaces.registered'
        msg['data'].keys.each { |ns|
          if Utukku::Engine::TagLib::Registry.instance.handler(ns).nil? ||
             Utukku::Engine::TagLib::Registry.instance.handler(ns).kind_of?(Utukku::Engine::TagLib::Remote)
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
    if mid.nil?
      @request_id += 1
      mid = "#{@request_id}"
    end
    if @connection.nil?
      @queue ||= [ ]
      @queue += [ { 'id' => mid, 'class' => klass, 'data' => data } ]
    else
      @connection.send([ klass, mid, data ])
    end
    mid
  end

  def clear_queue
    if !@connection.nil?
      @queue.each { |q| self.request(q['class'], q['data'], q['id']) }
    end
  end

  def wake
    @connection.wake
  end

  ## convenience method for calling functions
  def function(ns, nom, args, callbacks)
    context = Utukku::Engine::Context.new
    handler = Utukku::Engine::TagLib::Registry.instance.handler(ns)
    if handler.nil?
      callbacks[:done].call()
    else
      iterator = handler.function_to_iterator(context, nom, args)
      iterator.async(callbacks)
    end
  end
end
