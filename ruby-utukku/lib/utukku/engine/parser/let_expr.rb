class Utukku::Engine::Parser::LetExpr
  def initialize(dqname, expr)
    @expr = expr
    dqname =~ /^\$?(.*)$/
    @name = $1
  end

  def run(context, autovivify = false)
    result = @expr.run(context, autovivify)
    context.set_var(@name, result)
    return [ ]
  end
end
