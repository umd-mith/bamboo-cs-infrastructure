module Utukku
  module Engine
    class Iterator

      require 'utukku/engine/map_iterator'

      def start
      end

      def to_a
        @results = [ ]
        it = self.start
        until it.at_end?
          @results.push it.next
        end
        @results
      end

      def uniq
        seen = { }
        Utukku::Engine::SelectIterator.new(self) do |v|
          key = v
          if v.is_a?(Utukku::Engine::Memory::Node)
            key = v.value
          end
          if hash[key]
            false
          else
            hash[key] = true
          end
        end
      end

      def each(&block)
        it = self.start
        until it.at_end?
          yield it.next
        end
      end

      def collect(&block)
        Utukku::Engine::MapIterator.new(self, block)
      end

      def any(&block)
        visitor = self.start
        until visitor.at_end?
          return true if yield visitor.next
        end
        return false
      end

      def all(&block)
        visitor = self.start
        until visitor.at_end?
          return false unless yield visitor.next
        end
        return true
      end

      def async(callbacks)
        self.build_async(callbacks).call()
      end

      class Visitor
        def initialize(i)
          @iterator = i
        end

        def start
        end

        def position
          @position
        end

        def past_end?
          @past_end
        end

        def at_end?
          @at_end
        end
      end

    end
  end
end
