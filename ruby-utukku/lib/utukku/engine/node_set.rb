require 'utukku/engine/constant_iterator'

class Utukku::Engine::NodeSet < Utukku::Engine::ConstantIterator
  def children(n = nil)
    Utukku::Engine::NodeSet.new(@values.collect{ |c| c.children(n) }.flatten.uniq)
  end

  def parent
    Utukku::Engine::NodeSet.new(@values.collect{ |c| c.parent }.flatten.uniq)
  end

  def prune
    @values.each do |v|
      v.prune
    end
  end
end
