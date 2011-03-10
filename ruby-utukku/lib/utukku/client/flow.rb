require 'utukku/engine/constant_iterator'

class Utukku::Client::Flow
  attr_accessor :mid, :done

  def initialize(client, expression, namespaces, iterators, context, callbacks)
    @client = client
    @expression = expression
    @namespaces = namespaces
    @iterators = iterators
    @iterators.keys.each do |k|
      if !@iterators[k].is_a?(Utukku::Engine::Iterator) 
        @iterators[k] = Utukku::Engine::ConstantIterator.new(@iterators[k])
      end
    end
    @callbacks = callbacks
    @context = context
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
          if v.is_a?(Utukku::Engine::Memory::Node)
            if !v.vtype.nil? && v.vtype.join("") == Utukku::Engine::NS::FAB + "numeric"
              if v.value.denominator != 1
                @client.request('flow.provide', { k => [ "#{v.value.numerator}/#{v.value.denominator}" ] }, @mid)
              else
                @client.request('flow.provide', { k => [ v.value.numerator ] }, @mid)
              end
            elsif !v.vtype.nil? && v.vtype.join("") == Utukku::Engine::NS::FAB + "string"
              @client.request('flow.provide', { k => [ v.value ] }, @mid)
            else
              @client.request('flow.provide', { k => [ v.to_h ] }, @mid)
            end
          else
            @client.request('flow.provide', { k => [ v ] }, @mid)
          end
        },
        :done => proc {
          @client.request('flow.provided', [ k ], @mid)
        }
      })
    }
    @done = false
  end

  def message(klass, data)
    case klass
      when 'flow.produce'
        data.each { |i| 
          if i.is_a?(Hash)
            # build tree from hash
            i = @context.root.node_from_hash( i )
          elsif i =~ /^(-?\d+)\/(\d+)$/
            i = @context.root.anon_node( Rational($1, $2) )
          else
            i = @context.root.anon_node( i )
          end
          @callbacks[:next].call(i) 
        }
      when 'flow.produced'
        @done = true
        self.terminate
    end
  end

  def terminate
    @callbacks[:done].call()
    @client.request('flow.close', {}, @mid)
    @client.deregister_flow(self)
  end
end
