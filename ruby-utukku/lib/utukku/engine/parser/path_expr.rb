require 'utukku/engine/select_iterator'

class Utukku::Engine::Parser::PathExpr
  def initialize(pe, predicates, segment)
    @primary_expr = pe
    @predicates = Utukku::Engine::Parser::Predicates.new(nil, predicates)
    @segment = (segment.is_a?(Array) ? segment : [ segment ]) - [nil]
  end

  def expr_type(context)
    nil
  end

  def run(context, autovivify = false)
    if @primary_expr.nil?
      possible = [ context.root ]
    else
      possible = @primary_expr.run(context,autovivify).uniq
    end

    final = [ ]

    @segment = [ @segment ] unless @segment.is_a?(Array)

    possible.each do |e|
      next if e.nil?
      pos = @predicates.run(context.with_root(e), autovivify)
      next if pos.empty?
      @segment.each do |s|
        pos = pos.collect{ |p| 
          s.run(context.with_root(p), autovivify) 
        }.flatten - [ nil ]
      end
        
      final = final + pos
    end

    return final
  end

  def build_async(context, av, callbacks)
    if @primary_expr.nil?
      possible = [ context.root ]
    else
      possible = @primary_expr.run(context, av)
    end

    possible = possible.to_iterator

    Utukku::Engine::MapIterator.new(
      Utukku::Engine::SelectIterator.new(possible) { |n|
        !n.nil? &&
        !(@predicates.run(context.with_root(n), av).to_a - [nil]).empty?
      }
    ) { |n|
      pos = [ n ].to_iterator
      @segment.each do |s|
         pos = pos.collect { |p|
           s.run(context.with_root(p), av)
         }
      end
      pos
    }.build_async(callbacks)
  end
end
