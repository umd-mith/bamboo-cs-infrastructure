class Utukku::Agent::FlowIterator < Utukku::Engine::Iterator
  def initialize
    @cache = [ ]
    @listeners = [ ]
    @finishers = [ ]
    @is_done = false
  end

  def async(callbacks)
    proc {
      @cache.each { |v| callbacks[:next].call(v) }
      if @is_done
        callbacks[:done].call()
      else
        @listeners.push(callbacks[:next])
        @finishers.push(callbacks[:done])
      end
    }
  end

  def push(v)
    return if @is_done
    @cache.push(v)
    @listeners.each { |n| n.call(v) }
  end

  def done
    @is_done = true
    @finishers.each { |d| d.call() }
  end
end
