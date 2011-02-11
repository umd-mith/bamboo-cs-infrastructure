class Utukku::Engine::Parser::Literal
  def initialize(e, t = nil)
    @lit = e
    @type = t
  end

  def expr_type(context)
    @type
  end

  def run(context, autovivify = false)
    return [ context.root.anon_node(@lit, @type) ]
  end

  def invert(context, av, callbacks)
    proc {
      callbacks[:next].call(context.root.anon_node(@lit, @type))
      callbacks[:done].call()
    }
  end
end

class Utukku::Engine::Parser::Var
  def initialize(v)
    @var = v
  end

  def expr_type(context)
    v = context.get_var(@var)
    if( v.is_a?(Array) )
      TagLib.unify_types(v.collect{ |i| i.vtype })
    else
      v.vtype
    end
  end

  def run(context, autovivify = false)
    v = context.get_var(@var)
    return [] if v.nil?
    return v.is_a?(Array) ? v : [ v ]
  end

  def invert(context, av, callbacks)
    proc {
      v = context.get_var(@var)
      if v.is_a?(Utukku::Engine::Iterator)
        v.invert(callbacks)
      elsif v.is_a?(Array)
        v.each { |i| callbacks[:next].call(i) }
        callbacks[:done].call()
      else
        callbacks[:next].call(v)
        callbacks[:done].call()
      end
    }
  end
end
