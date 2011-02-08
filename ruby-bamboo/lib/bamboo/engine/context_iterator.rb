class Bamboo::Engine::ContextIterator < Bamboo::Engine::Iterator
  def initialize(context, iterator, trans = nil)
    @context = context
    @iterator = iterator
    @transform = trans
  end

  def transform(&block)
    self.class.new(@context, @iterator, block)
  end

  def async(callbacks)
    Bamboo::Engine::MapIterator.new(
      @iterator,
      proc { |r|
        ctx = @context.with_root(r)
        @transform.nil? ? ctx : @transform.call(ctx)
      }
    ).async(callbacks)
  end
end
