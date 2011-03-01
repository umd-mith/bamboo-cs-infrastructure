module Utukku::Engine::Core::Actions
  class ValueOf < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    has_select

    def run(context, autovivify = false)
      @select.run(@context.merge(context), autovivify)
    end
  end

  class Value < Utukku::Engine::Action
    attr_accessor :select, :name

    namespace Utukku::Engine::NS::FAB
    attribute :path, :static => true
    has_select nil
    has_actions

    def run(context, autovivify = false)
      @context.with(context) do |ctx|
        ctx.set_value(self.path, @select.nil? ? @actions : @select )
      end
    end
  end

  class Variable < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    attribute :name, :eval => false, :static => true
    has_select nil
    has_actions

    def run(context, autovivify = false)
      return [] if self.name.nil?
      res = [ ]
      @context.with(context) do |ctx|
        if !@select.nil?
          res = self.select(ctx)
        else
          res = self.run_actions(ctx)
        end
      end
      context.set_var(self.name, res)
      res
    end
  end
end
