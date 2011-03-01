require 'utukku/client/flow'

class Utukku::Client::FlowIterator < Utukku::Engine::Iterator
  def initialize(client, expression, namespaces, iterators, context)
    @client = client
    @expression = expression
    @namespaces = namespaces
    @iterators = iterators
    @context = context
  end

  def build_async(callbacks)
    flow = Utukku::Client::Flow.new(
      @client,
      @expression,
      @namespaces,
      @iterators,
      @context,
      callbacks
    )

    flow.create

    proc { flow.run }
  end

  def start
    raise "Unable to run flows synchronously for now"
  end
end
