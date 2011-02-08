class Bamboo::Engine::Parser::RootContext
  def initialize(axis = nil)
    @axis = axis
  end

  def run(context, autovivify = false)
    c = nil
    if @axis.is_a?(String)
      c = context.root.root(@axis)
    elsif !@axis.nil?
      c = @axis.run(context, autovivify).first
    else
      c = context.root.root
    end
    return [ ] if c.nil?
    return [ c ]
  end

  def create_node(context)
    if context.root.root(@axis).nil?
      context.root.roots[@axis] = Bamboo::Engine::Memory::Node.new(@axis,context.root.roots,nil,[])
    end
    context.root.root(@axis)
  end
end

class Bamboo::Engine::Parser::CurrentContext
  def initialize
  end

  def run(context, autovivify = false)
    context.nil? ? [] : [ context.root ]
  end

  def create_node(context)
    context.root
  end
end
