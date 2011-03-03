require 'utukku/engine/iterator'

module Utukku
  module Engine
    class ConstantIterator < Iterator
      attr_reader :values

      def initialize(v)
        if v.is_a?(Array)
          @values = v
        else
          @values = [ v ]
        end
      end

      def start
        ConstantIterator::Visitor.new(self)
      end

      def build_async(callbacks)
        proc {
          @values.each do |v|
            callbacks[:next].call(v)
          end
          callbacks[:done].call()
        }
      end

      class Visitor < Iterator::Visitor
        def initialize(i)
          @iterator = i
          @position = 0
          @past_end = false
        end

        def at_end?
          @position >= @iterator.values.length
        end

        def past_end?
          @past_end
        end

        def next
          if self.at_end?
            @past_end = true
            @value = nil
          else
            @value = @iterator.values[@position]
            @position += 1
          end
          @value
        end
      end
    end
  end
end
