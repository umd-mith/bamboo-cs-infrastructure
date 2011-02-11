class Utukku::Client::Flow
  attr_accessor :mid

  def initialize(client, expression, namespaces, iterators, callbacks)
    @client = client
    @expression = expression
    @namespaces = namespaces
    @iterators = iterators
    @callbacks = callbacks
  end

  def create
    @mid = @client.request('flow.create', {
      'expression' => @expression,
      'iterators' => @iterators.keys,
      'namespaces' => @namespaces
    })
    @client.register_flow(self)
  end

  def run
    self.create if @mid.nil?

    @iterators.keys.collect { |k|
      @iterators[k].async({
        :next => proc { |v|
          @client.request('flow.provide', {
            'iterators' => { k => v }
          }, @mid)
        },
        :done => proc {
          @client.request('flow.provided', {
            'iterators' => [ k ]
          }, @mid)
        }
      })
    }
  end

  def message(klass, data)
    case klass
      when 'flow.produce'
        data['items'].each { |i| @callbacks[:next].call(i) }
      when 'flow.produced'
        self.terminate
    end
  end

  def terminate
    @callbacks[:done].call()
    @client.request('flow.close', {}, @mid)
    @client.deregister_flow(self)
  end
end
