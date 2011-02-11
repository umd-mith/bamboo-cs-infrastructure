class Utukku::Engine::ReductionIterator
  def initialize(iterator, callbacks)
    @iterator = iterator
    @function = callbacks
  end

  def build_async(callbacks)
    @iterator.async({
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
