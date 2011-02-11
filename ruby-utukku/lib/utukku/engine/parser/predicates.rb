class Utukku::Engine::Parser::Predicates
  def initialize(axis,p)
    @axis = axis
    @predicates = p
  end

  def run(context, autovivify = false)
    # we want to run through all of the predicates and return true if
    # they all return true
    result = [ ]
    possible = @axis.nil? ? [ context.root ] : @axis.run(context, autovivify)
    return possible if @predicates.nil? || @predicates.empty?
    @predicates.each do |p|
      n_p = [ ]
      context.with_roots(possible) do |ctx|
        if p.is_a?(Array)
          res = p.collect{ |pp| pp.run(ctx) }.flatten
        else
          res = p.run(ctx)
        end
        if res.is_a?(Array)
          res -= [ nil ]
          if !res.empty?
            # if all boolean and one is true, then keep
            # if numeric, then keep if position == number
            # if string and non-blank, then keep
            unified_type = Utukku::Engine::TagLib.unify_types(res.collect{ |r| r.vtype })
            case unified_type.join('') 
              when Utukku::Engine::NS::FAB+'boolean'
                if res.select{ |r| r.to([Utukku::Engine::NS::FAB, 'boolean']).value }.size > 0
                  n_p << ctx.root
                end
              when Utukku::Engine::NS::FAB+'numeric'
                if res.select{ |r| r.to([Utukku::Engine::NS::FAB,'numeric']).value == ctx.position }.size > 0
                  n_p << ctx.root
                end
              when Utukku::Engine::NS::FAB+'string'
                if res.select{ |r| r.to_s.size > 0 }.size > 0
                  n_p << ctx.root
                end
              else # default for now is to convert to boolean
                if res.select{ |r| r.to([Utukku::Engine::NS::FAB, 'boolean']).value }.size > 0
                  n_p << ctx.root
                end
            end
          end
        else
          n_p << ctx.root if !!res.value
        end
      end
      possible = n_p
    end
    return possible
  end
end
