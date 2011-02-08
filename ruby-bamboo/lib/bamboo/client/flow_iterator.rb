require 'bamboo/client/flow'

class Bamboo::Client::FlowIterator < Bamboo::Engine::Iterator
  def initialize(client, expression, namespaces, iterators)
    @client = client
    @expression = expression
    @namespaces = namespaces
    @iterators = iterators
  end

  def async(callbacks)
    flow = Bamboo::Client::Flow.new(
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
