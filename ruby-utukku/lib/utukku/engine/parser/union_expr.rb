require 'utukku/engine/union_iterator'

class Utukku::Engine::Parser::UnionExpr
  def initialize(es)
    @exprs = es
  end

  def expr_type(context)
    Utukku::Engine::TagLib.unify_types(@exprs.collect{ |e| e.expr_type(context) })
  end

  def run(context, autovivify = false)
    #Utukku::Engine::UnionIterator.new(@exprs.collect{ |x| x.run(context, autovivify) })
    @exprs.inject([]) { |r,x| r + x.run(context, autovivify) }
  end
end
