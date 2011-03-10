require 'utukku/engine/iterator'
require 'utukku/engine/constant_iterator'

class Utukku::Engine::UnionIterator < Utukku::Engine::Iterator
  def initialize(iterators)
    @iterators = iterators
  end

  def start
    Utukku::Engine::UnionIterator::Visitor.new(@iterators)
  end

  def build_async(callbacks)
    done = 0
    next_callbacks = {
      :next => callbacks[:next],
      :done => proc {
        done += 1
        if done >= @iterators.length
          callbacks[:done].call()
        end
      }
    }

    inits = @iterators.collect{ |i| 
      if !i.is_a?(Utukku::Engine::Iterator)
        i = Utukku::Engine::ConstantIterator.new(i)
      end
      i.build_async(next_callbacks) 
    }

    # we could call these in parallel
    proc {
      inits.each { |i| i.call() }
    }
  end

  class Visitor < Utukku::Engine::Iterator::Visitor
    def initialize(its)
      @iterators = its.collect { |i| i.start }
      @value = nil
      @position = 0
      @past_end = false
    end

    def at_end?
      @iterators.empty?
    end

    def past_end?
      @past_end
    end

    def next
      if self.at_end?
        @value = nil
        @past_end = true
      else
        @value = @iterators.first.next
        if @iterators.first.at_end?
          @iterators.shift
        end
        @position += 1
      end
      @value
    end
  end
end
