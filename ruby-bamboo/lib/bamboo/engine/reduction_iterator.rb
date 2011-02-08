class Bamboo::Engine::ReductionIterator
  def initialize(iterator, callbacks)
    @iterator = iterator
    @function = callbacks
  end

  def async(callbacks)
    @iterator.async({
      :next => @function[:next],
      :done => proc {
        v = @function[:done].call()
        if v.kind_of?(Bamboo::Engine::Iterator)
          v.async(callbacks).each { |s| s.call() }
        else
          callbacks[:next].call(v)
          callbacks[:done].call()
        end
      }
    })
  end
end
