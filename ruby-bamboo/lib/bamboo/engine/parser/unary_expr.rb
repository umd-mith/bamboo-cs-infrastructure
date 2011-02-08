class Bamboo::Engine::Parser::UnaryExpr
  def initialize(e)
    @expr = e
  end

  def run(context, autovivify = false)
    l = @expr.run(context, autovivify)

    l = [ l ] unless l.is_a?(Array)

    l = l.collect { |i| i.value }.uniq - [ nil ]

    return @expr.collect{|e|  Bamboo::Engine::Memory::Node.new(
          context.root.axis,
          context.root.roots,
          self.calculate(e),
          []
        ) }
  end
end

class Bamboo::Engine::Parser::NegExpr < Bamboo::Engine::Parser::UnaryExpr
  def calculate(e)
    e.nil? ? nil : -e
  end
end
