# predeclare so we avoid circular references
class Utukku::Engine::Iterator::Visitor
end

class Utukku::Engine::MapIterator < Utukku::Engine::Iterator

  attr_accessor :mapping, :iterator

  def initialize(it, &block)
    if it.kind_of?(Array) 
      it = it.flatten
      if it.empty?
        @iterator = Utukku::Engine::NullIterator.new
      elsif it.length == 1
        @iterator = it.first
      else
        @iterator = Utukku::Engine::UnionIterator.new(it)
      end
    elsif !it.is_a?(Utukku::Engine::Iterator)
      @iterator = Utukku::Engine::ConstantIterator.new(it)
    else
      @iterator = it
    end
    @mapping = block
  end

  def start
    Utukku::Engine::MapIterator::Visitor.new(self)
  end

  def build_async(callbacks)
    @iterator.build_async({
      :next => proc { |v|
        ret = @mapping.call(v)
        if ret.kind_of?(Utukku::Engine::Iterator)
          ret.async({ :next => callbacks[:next], :done => proc { } })
        else
          callbacks[:next].call(ret)
        end
      },
      :done => callbacks[:done]
    })
  end

  class Visitor < Utukku::Engine::Iterator::Visitor
    def initialize(it)
      super
      @sub_iterator = nil
      @visitor = @iterator.iterator.start
    end

    def at_end?
      @at_end
    end

    def next
      if @at_end
        @value = nil
        @past_end = true
      elsif @sub_iterator && !@sub_iterator.at_end?
        @value = @sub_iterator.next
        if @sub_iterator.at_end?
          @sub_iterator = nil
          if @visitor.at_end?
            @at_end = true
          end
        end
      else
        v = @iterator.mapping.call(@visitor.next)
        if v.is_a?(Utukku::Engine::Iterator)
          @sub_iterator = v.start
          @value = @sub_iterator.next
        else
          @value = v
          if @visitor.at_end?
            @at_end = true
          end
        end
      end
      @value
    end

    def value
      @value
    end
  end
end
