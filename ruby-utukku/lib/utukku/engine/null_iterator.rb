require 'utukku/engine/iterator'

class Utukku::Engine::NullIterator < Utukku::Engine::Iterator
  def initialize
  end

  def start
    Utukku::Engine::NullIterator::Visitor.new
  end

  def build_async(callbacks)
    callbacks[:done]
  end

  class Utukku::Engine::NullIterator::Visitor < Utukku::Engine::Iterator
    def initialize
    end

    def at_end?
      true
    end

    def value
      nil
    end

    def next
      nil
    end

    def past_end?
      true
    end
  end
end
