require 'utukku/engine/iterator'

class Utukku::Engine::NullIterator < Utukku::Engine::Iterator
  def initialize
  end

  def start
  end

  def build_async(callbacks)
    callbacks[:done]
  end
end
