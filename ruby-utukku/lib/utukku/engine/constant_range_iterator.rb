require 'utukku/engine/iterator'

module Utukku
  module Engine
    class ConstantRangeIterator < Iterator
      attr_accessor :first, :last, :incr
      def initialize(first, fin, incr = nil)
        @first = first
        @last = fin
        @incr = incr.nil? ? ((@first < @last) ? 1 : -1) : incr
      end

      def start
        ConstantRangeIterator::Visitor.new(self)
      end

      def build_async(callbacks)
        visitor = self.start
        proc {
          until visitor.at_end?
            callbacks[:next].call(visitor.next)
          end
          callbacks[:done].call()
        }
      end

      class Visitor < Iterator::Visitor
        def initialize(i)
          @iterator = i
          @value = nil
          @at_end = false
          @past_end = false
          @position = 0
        end

        def at_end?
          @at_end
        end

        def past_end?
          @past_end
        end

        def next
          if self.at_end?
            @past_end = true
            @value = nil
          elsif @value.nil?
            @value = @iterator.first
            @position = 1
            @at_end = @iterator.first == @iterator.last
          elsif (( @iterator.incr > 0 && (@value + @iterator.incr) <= @iterator.last) ||
                 (@iterator.incr < 0 && (@value + @iterator.incr) >= @iterator.last))
            @value += @iterator.incr
            @position += 1
            @at_end = @iterator.incr > 0 && @value + @iterator.incr > @iterator.last || @iterator.incr < 0 && @value + @iterator.incr < @iterator.last
          else
            @at_end = true
            @value = nil
          end
          @value
        end
      end
    end
  end
end
