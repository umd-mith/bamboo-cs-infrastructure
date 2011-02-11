class Utukku::Engine::Parser::ForExpr
  def initialize(v, e)
    if v.size > 1
      @var = v.shift
      @expr = Utukku::Engine::Parser::ForExpr.new(v, e)
    else
      @var = v.first
      @expr = e
    end
  end

  def expr_type(context)
    @expr.expr_type(context)
  end

  def run(context, autovivify = false)
    result = [ ]
    return result if @var.nil? || @expr.nil?

    count = 1
    @var.each_binding(context, autovivify) do |b|
      b.position = count
      result = result + @expr.run(b)
      count += 1
    end
    return result
  end
end

class Utukku::Engine::Parser::EveryExpr < Utukku::Engine::Parser::ForExpr
  def expr_type(context)
    [ FAB_NS, 'boolean' ]
  end

  def run(context, autovivify = false)
    result = super
    result.each do |r|
      return [ context.root.anon_node(false) ] unless !!r.value
    end
    return [ context.root.anon_node(true) ]
  end
end

class Utukku::Engine::Parser::SomeExpr < Utukku::Engine::Parser::ForExpr
  def expr_type(context)
    [ FAB_NS, 'boolean' ]
  end

  def run(context, autovivify = false)
    result = super
    result.each do |r|
      return [ context.root.anon_node(true) ] if !!r.value
    end
    return [ context.root.anon_node(false) ]
  end
end

class Utukku::Engine::Parser::ForVar
  def initialize(n, e)
    n =~ /^\$?(.*)$/
    @var_name = $1
    @expr = e
  end

  def each_binding(context, autovivify = false, &block)
    @expr.run(context, autovivify).each do |e|
      context.in_context do |ctx|
        ctx.set_var(@var_name, e)
        yield ctx
      end
    end
  end
end
