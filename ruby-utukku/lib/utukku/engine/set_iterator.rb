require 'utukku/engine/iterator'

class Utukku::Engine::SetIterator < Utukku::Engine::Iterator
  attr_accessor :combinator, :sets
  def initialize(sets, &block)
    @sets = sets.flatten
    @combinator = block
  end

  def start
    Utukku::Engine::SetIterator::Visitor.new(self)
  end

  def build_async(callbacks)
    self.build_partial_async({
      :done => callbacks[:done],
      :next => proc { |bits|
        r = @combinator.call(bits)
        if r.kind_of?(Utukku::Engine::Iterator)
          r.async({
            :done => proc { },
            :next => callbacks[:next]
          })
        else
          callbacks[:next].call(r)
        end
      }
    }, @sets)
  end

  def build_partial_async(callbacks, sets)
    if sets.length > 1
      set = sets.first
      set.build_async({
        :done => callbacks[:done],
        :next => proc { |v|
          self.build_partial_async({
            :done => proc { },
            :next => proc { |bits|
              callbacks[:next].call([ v ] + bits)
            }
          }, sets[1..sets.length-1]).call()
        }
      })
    else
      sets.first.build_async({
        :done => callbacks[:done],
        :next => proc { |v| callbacks[:next].call([v]) }
      })
    end
  end

  class Visitor < Utukku::Engine::Iterator::Visitor
    def initialize(i)
      super
      @sets = @iterator.sets.collect{ |s| s.start }
      @at_end = @sets.select{ |s| !s.at_end? }.size == 0
      @sets[1..@sets.length-1].each do |s|
        s.next
      end
    end

    def next
      if @at_end
        @value = nil
        @past_end = true
      elsif @sub_iterator
        @value = @sub_iterator.next
        if @sub_iterator.at_end?
          @sub_iterator = nil
          if @sets.collect{ |s| !s.at_end?}.size == 0
            @at_end = true
          end
        end
      else
        i = 0
        n = @sets.length - 1
        @sets.first.next
        while i < n && @sets[i].past_end?
          @sets[i] = @iterator.sets[i].start
          @sets[i].next
          if i < n
            @sets[i+1].next
          end
          i += 1
        end
        r = @iterator.combinator.call(@sets.collect{ |s| s.value })
        if r.is_a?(Utukku::Engine::Iterator)
          @sub_iterator = r.start
          @value = @sub_iterator.next
        else
          @value = r
        end
      end
      @value
    end

    def at_end?
      @at_end
    end
  end
end
