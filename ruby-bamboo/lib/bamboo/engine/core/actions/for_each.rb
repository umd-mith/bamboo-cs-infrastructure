module Bamboo::Engine::Core::Actions
  class ForEach < Bamboo::Engine::Structural
    namespace Bamboo::Engine::NS::FAB

    attribute :as, :static => true

    contains :sort

    has_select
    has_actions

    def run(context, autovivify = false)
      @context.with(context) do |ctx|
        items = self.select(ctx)
        res = nil
        ctx.in_context do |c|
          if !@sorts.empty?
            if self.as.nil?
              items = items.sort_by{ |i| 
                @sorts.collect{|s| s.run(c.with_root(i)) }.join("\0") 
              }
            else
              items = items.sort_by{ |i| 
                r = nil
                c.in_context do |cc|
                  cc.set_var(self.as, i)
                  r = @sorts.collect{|s| s.run(cc.with_root(i)) }.join("\0") 
                end
                r
              }
            end
          end
          res = [ ]
          if self.as.nil?
            items.each do |i|
              res = res + self.run_actions(c.with_root(i))
            end
          else
            items.each do |i|
              c.in_context do |cc|
                cc.set_var(self.as, i) unless self.as.nil?
                res = res + self.run_actions(cc.with_root(i))
              end
            end
          end
        end
        return res
      end
    end
  end

  class Sort < Bamboo::Engine::Action
    namespace Bamboo::Engine::NS::FAB
    has_select

    def run(context, autovivify = false)
      (self.select(@context.merge(context)).first.to_s rescue '')
    end
  end

end
