class Utukku::Engine::Parser::IfExpr
  def initialize(t, a, b)
    @test = t
    @then_expr = a
    @else_expr = b
  end

  def run(context, autovivify = false)
    res = @test.run(context.merge)

    if res.nil? || res.empty? || !res.first.value
      res = @else_expr.nil? ? [] : @else_expr.run(context.merge, autovivify)
    else
      res = @then_expr.run(context.merge, autovivify)
    end
    return res
  end

  def build_async(context, autovivify, callbacks)
    then_run = false
    @test.build_async(context,false,{
      :next => proc { |b|
        if !then_run && !b.nil? && !!b.value
          then_run = true
          @then_expr.async(context, autovivify, callbacks)
        end
      },
      :done => proc {
        if !then_run && @else_expr
          @else_expr.async(context, autovivify, callbacks)
        else
          callbacks[:done].call()
        end
      }
    })
  end
end
