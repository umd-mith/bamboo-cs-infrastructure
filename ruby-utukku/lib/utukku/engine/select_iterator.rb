class Utukku::Engine::SelectIterator < Utukku::Engine::Iterator
  attr_accessor :selection, :iterator

  def initialize(it, &block)
    @iterator = it
    @selection = block
  end

  def start
    Utukku::Engine::SelectIterator::Visitor.new(self)
  end

  def build_async(callbacks)
    hash = { }
    @iterator.build_async({
      :next => proc { |v|
#        key = v
#        if v.is_a?(Utukku::Engine::Memory::Node)
#          key = v.value
#        end
#        unless hash[key]
#          hash[key] = true
        if @selection.call(v)
          callbacks[:next].call(v)
        end
      },
      :done => callbacks[:done]
    })
  end

  class Visitor < Utukku::Engine::Iterator::Visitor
    def initialize(i)
      super
      @visitor = @iterator.iterator.start
      @position = 0
      @at_end = false
      self.get_next
    end

    def at_end?
      @at_end
    end

    def get_next
      if @visitor.at_end?
        @at_end = true
        @next = nil
      else
        v = @visitor.next
        while !@iterator.selection.call(v) && !@visitor.at_end?
          v = @visitor.next
        end
        if @visitor.at_end?
          @at_end = true
          @next = nil
        else
          @next = v
        end
      end
    end

    def next
      if self.at_end?
        @past_end = true
        @value = nil
      else
        @position += 1
        @value = @next
        self.get_next
      end
      @value
    end
  end
end
