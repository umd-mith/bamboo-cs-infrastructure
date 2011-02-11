require 'utukku/client/flow'

class Utukku::Client::FlowIterator < Utukku::Engine::Iterator
  def initialize(client, expression, namespaces, iterators)
    @client = client
    @expression = expression
    @namespaces = namespaces
    @iterators = iterators
  end

  def async(callbacks)
    flow = Utukku::Client::Flow.new(
      @client,
      @expression,
      @namespaces,
      @iterators,
      callbacks
    )

    flow.create

    proc { flow.run }
  end

  def start
    raise "Unable to run flows synchronously for now"
  end
end
