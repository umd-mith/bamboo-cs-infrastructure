require 'utukku/engine/parser'
require 'utukku/engine/context'
require 'utukku/agent/flow_iterator'

class Utukku::Engine::Flow < Utukku::Engine::Iterator
  def initialize(namespaces, expression, iterators)
    @expression = expression
    @iterators = iterators
    @namespaces = namespaces

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

  def build_async(callbacks)
    @parsed_expr.build_async(@context, false, callbacks)
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

  def finish

  end
end
