require 'utukku/engine/constant_iterator'
require 'utukku/engine/constant_range_iterator'
require 'utukku/engine/set_iterator'

module Utukku
  module Engine
    class RangeIterator

      def initialize(first, last, incr)
        @first = first
        @last = last
        @incr = incr || Utukku::Engine::ConstantIterator.new([ @first < @last ? 1 : -1 ])
      end

      def start
        RangeIterator::Visitor.new(self)
      end

      def invert(callbacks)
        Utukku::Engine::SetIterator.new([@first, @last, @incr], proc { |first, last, incr|
          Utukku::Engine::ConstantRangeIterator.new(first, last, incr)
        }).invert({
          :done => callbacks[:done],
          :next => proc { |i|
            i.invert({
              :next => calbacks[:next],
              :done => proc { }
            }).call()
          }
        })
      end

      class Visitor
        def initialize(i)
          @iterator = i
          @position = 0
          @value = nil
          @past_end = false
          @at_end = false

          @bounds_iterator = Utukku::Engine::SetIterator.new([        
            @iterator.first, @iterator.last, @iterator.incr
          ], proc { |first, last, incr|
            Utukku::Engine::ConstantRangeIterator.new(first, last, incr).start
          }).start
           
          @bounds_visitor = @bounds_iterator.next
        end

        def next
          if self.at_end?
            @past_end = true
            @value = undef
          else
            @bounds_visitor.next
            if @bounds_visitor.past_end? 
              @bounds_visitor = @bounds_iterator.next
              @bounds_visitor.next
            end
            @value = @bounds_visitor.value
            @position += 1
          end
          if @bounds_visitor.at_end? && @bounds_iterator.at_end?
            @at_end = true
          end
          @value
        end

      end
    end
  end
end
