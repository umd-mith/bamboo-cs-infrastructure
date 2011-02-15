class Utukku::Agent::FlowIterator < Utukku::Engine::Iterator
  def initialize
    @cache = [ ]
    @should_cache = nil
    @listeners = [ ]
    @finishers = [ ]
    @is_done = false
  end

  def cache=(f)
    @should_cache = f
  end

  def cache?
    @should_cache
  end

  def at_end?
    @is_done
  end

  def build_async(callbacks)
    proc {
      @cache.each { |v| callbacks[:next].call(v) } if @should_cache.nil? || @should_cache
      if @is_done
        callbacks[:done].call()
      else
        if @should_cache.nil?
          @should_cache = false
          @cache = nil
        end
        @listeners.push(callbacks[:next])
        @finishers.push(callbacks[:done])
      end
    }
  end

  def push(v)
    return if @is_done
    @cache.push(v) if @should_cache.nil? || @should_cache
    @listeners.each { |n| n.call(v) }
  end

  def done
    @is_done = true
    @finishers.each { |d| d.call() }
  end
end
