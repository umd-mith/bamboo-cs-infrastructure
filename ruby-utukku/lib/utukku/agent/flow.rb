require 'utukku/engine/parser'
require 'utukku/engine/context'
require 'utukku/agent/flow_iterator'

class Utukku::Agent::Flow
  def initialize(agent, data, msg_id)
    @expression = data['expression']
    @iterators = data['iterators']
    @namespaces = data['namespaces']
    @msg_id = msg_id
    @agent = agent

    @context = Utukku::Engine::Context.new

    @namespaces.each_pair do |p,h|
      @context.set_ns(p,h)
    end

    @iterator_objs = { }
    @iterators.each do |i|
      @iterator_objs[i] = Utukku::Agent::FlowIterator.new
      @context.set_var(i, @iterator_objs[i])
    end

    parser = Utukku::Engine::Parser.new

    @parsed_expr = parser.parse(@expression, @context)
  end

  def start
    @parsed_expr.async(@context, false, {
      :next => proc { |v|
        @agent.response('flow.produce', [ v ], @msg_id)
      },
      :done => proc {
        @agent.response('flow.produced', {}, @msg_id)
      }
    })
  end

  def provide(iterators)
    iterators.each_pair do |i,v|
      @iterator_objs[i].push(@context.root.anon_node(v))
    end
  end

  def provided(iterators)
    iterators.each do |i|
      @iterator_objs[i].done
    end
  end

  def provided?
    @iterator_objs.values.collect{ |i| !i.at_end? }.size == 0
  end

  def finish

  end
end
