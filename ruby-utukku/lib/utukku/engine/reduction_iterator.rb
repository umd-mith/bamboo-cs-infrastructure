require 'utukku/engine/constant_iterator'

class Utukku::Engine::ReductionIterator
  def initialize(iterator, callbacks)
    @iterator = iterator
    @iterator = Utukku::Engine::ConstantIterator.new(@iterator) unless @iterator.is_a?(Utukku::Engine::Iterator)
    @function = callbacks
  end

  def build_async(callbacks)
    @iterator.build_async({
      :next => @function[:next],
      :done => proc {
        v = @function[:done].call()
        if v.kind_of?(Utukku::Engine::Iterator)
          v.async(callbacks)
        else
          callbacks[:next].call(v)
          callbacks[:done].call()
        end
      }
    })
  end
end
