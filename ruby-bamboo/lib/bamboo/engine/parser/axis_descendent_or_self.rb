require 'bamboo/engine/expression'

class Bamboo::Engine::Parser::AxisDescendentOrSelf < Bamboo::Engine::Expression
  def initialize(step = nil)
    @step = step
  end

  def run(context, autovivify = false)
    if context.is_a?(Array)
      stack = context.root
    else
      stack = [ context.root ]
    end
    possible = [ ]
    while !stack.empty?
      c = stack.shift

      stack = stack + c.children

      possible = possible + context.with_root(c).run(@step, autovivify)
    end
    return possible.uniq
  end
end
