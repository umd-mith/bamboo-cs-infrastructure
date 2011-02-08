require 'bamboo/engine/iterator'

class Bamboo::Engine::NullIterator < Bamboo::Engine::Iterator
  def initialize
  end

  def start
  end

  def async(callbacks)
    callbacks[:done]
  end
end
