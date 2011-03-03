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
        if v.is_a?(Utukku::Engine::Memory::Node)
          if v.value.is_a?(Numeric)
            if v.value.denominator != 1
              @agent.response('flow.produce', [ "#{v.value.numerator}/#{v.value.denominator}" ], @msg_id)
            else
              @agent.response('flow.produce', [ v.value.numerator ], @msg_id)
            end
          elsif !v.value.nil?
            @agent.response('flow.produce', [ v.to_s ], @msg_id)
          else # children?
            @agent.response('flow.produce', [ v.to_h ], @msg_id)
          end
        else
          @agent.response('flow.produce', [ v ], @msg_id)
        end
      },
      :done => proc {
        @agent.response('flow.produced', {}, @msg_id)
      }
    })
  end

  def provide(iterators)
    iterators.each_pair do |i,v|
      if v =~ /^(-?\d+)\/(\d+)$/
        v = Rational($1.to_i, $2.to_i)
      end
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
