class Utukku::Engine::MapIterator < Utukku::Engine::Iterator

  def initialize(it, mapping)
    if it.kind_of?(Array) 
      it = it.flatten
      if it.empty?
        @iterator = Utukku::Engine::NullIterator.new
      elsif it.length == 1
        @iterator = it.first
      else
        @iterator = Utukku::Engine::UnionIterator.new(it)
      end
    elsif !it.is_a?(Utukku::Engine::Iterator)
      @iterator = Utukku::Engine::ConstantIterator.new(it)
    else
      @iterator = it
    end
    @mapping = mapping
  end

  def build_async(callbacks)
    @iterator.build_async({
      :next => proc { |v|
        ret = @mapping.call(v)
        if ret.kind_of?(Utukku::Engine::Iterator)
          ret.async({ :next => callbacks[:next], :done => proc { } })
        else
          callbacks[:next].call(ret)
        end
      },
      :done => callbacks[:done]
    })
  end

end
