module Utukku::Engine::Core::Actions
  class Choose < Utukku::Engine::Structural

    namespace Utukku::Engine::NS::FAB

    contains :when, :as => :choices
    contains :otherwise, :as => :default

    def run(context, autovivify = false)
      @context.with(context) do |ctx|
        @choices.each do |c|
          if c.run_test(ctx)
            return c.run(ctx)
          end
        end
        return @default.first.run(ctx) unless @default.empty?
        return []
      end
    end
  end

  class When < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    attribute :test, :eval => true, :static => false

    has_actions

    def run_test(context)
      return true if @test.nil?
      result = self.test(@context.merge(context)).collect{ |a| !!a.value }
      return false if result.nil? || result.empty? || !result.include?(true)
      return true
    end
  end

  class If < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    attribute :test, :eval => true, :static => false

    has_actions

    def run(context, autovivify = false)
      return [ ] if @test.nil?
      @context.with(context) do |ctx|
        test_res = self.test(ctx).collect{ |a| !!a.value }
        return [ ] if test_res.nil? || test_res.empty? || !test_res.include?(true)
        return self.run_actions(ctx)
      end
    end
  end

  class Block < Utukku::Engine::Action

    namespace Utukku::Engine::NS::FAB
    has_actions

  end

  class Goto < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    attribute :test, :eval => true, :static => false
    attribute :state, :static => true

    def run(context, autovivify = false)
      raise Utukku::Engine::StateChangeException, @state, caller if @test.nil?
      test_res = @test.run(@context.merge(context)).collect{ |a| !!a.value }
      return [ ] if test_res.nil? || test_res.empty? || !test_res.include?(true)
      raise Utukku::Engine::StateChangeException, @state, caller
    end
  end

  class Catch < Utukku::Engine::Action
    namespace Utukku::Engine::NS::FAB
    attribute :test, :eval => true, :static => false
    attribute :as, :static => true

    has_actions

    def run_test(context)
      return true if @test.nil?
      @context.with(context) do |ctx|
        ctx.set_var(@as, context) if @as
        result = self.test(context).collect{ |a| !!a.value }
        return false if result.nil? || result.empty? || !result.include?(true)
        return true
      end
    end

    def run(context, autovivify = false)
      @context.with(context) do |ctx|
        ctx.set_var(self.as, context) if self.as
        return self.run_actions(context)
      end
    end
  end

  class Raise < Utukku::Engine::Action
 
    namespace Utukku::Engine::NS::FAB
    attribute :test, :eval => true, :static => false
    has_actions

    def run(context, autovivify = false)
      @context.with(context) do |ctx|
        select = ctx.get_select
        if !@test.nil?
          test_res = self.test(ctx).collect{ |a| !!a.value }
          return [ ] if test_res.nil? || test_res.empty? || !test_res.include?(true)
        end
        res = [ ]
        if select.nil? && self.has_actions?
          res = self.run_actions(ctx)
        elsif !select.nil?
          res = select.run(ctx, autovivify)
        else
          raise ctx   # default if <raise/> with no attributes
        end

        return [ ] if res.empty?

        raise Utukku::Engine::Exception.new(res.first)
      end
    end
  end

end
