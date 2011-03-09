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
          if !v.vtype.nil? && v.vtype.join("") == Utukku::Engine::NS::FAB + "numeric"
            if v.value.denominator != 1
              @agent.response('flow.produce', [ "#{v.value.numerator}/#{v.value.denominator}" ], @msg_id)
            else
              @agent.response('flow.produce', [ v.value.numerator ], @msg_id)
            end
          elsif !v.vtype.nil? && v.vtype.join("") == Utukku::Engine::NS::FAB + "string"
            @agent.response('flow.produce', [ v.value ], @msg_id)
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
      v = v.to_a
      v.each do |vv|
        if vv.is_a?(Hash)
          vv = @context.root.node_from_hash(vv)
        elsif vv =~ /^(-?\d+)\/(\d+)$/
          vv = @context.root.anon_node(Rational($1.to_i, $2.to_i))
        else
          vv = @context.root.anon_node(vv)
        end
        @iterator_objs[i].push(vv)
      end
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
