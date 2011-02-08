class Bamboo::Engine::MapIterator < Bamboo::Engine::Iterator

  def initialize(it, mapping)
    @iterator = it
    @mapping = mapping
puts "iterator: #{@iterator}     mapping: #{@mapping}"
  end

  def async(callbacks)
    @iterator.async({
      :next => proc { |v|
puts "Calling with #{v}"
        ret = @mapping.call(v)
        if ret.kind_of?(Bamboo::Engine::Iterator)
          ret.async({ :next => callbacks[:next], :done => proc { } }).each { |s| s.call() }
        else
          callbacks[:next].call(ret)
        end
      },
      :done => callbacks[:done]
    })
  end

end
