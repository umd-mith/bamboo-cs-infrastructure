module Bamboo::Engine
  module Core
  module Structurals
  class Group <  Bamboo::Engine::Structural
    attr_accessor :name, :params, :tags, :required_params

    namespace Bamboo::Engine::NS::FAB

    contains 'group', :as => :groups
    contains 'param', :as => :params
    contains 'constraint', :as => :constraints
    contains 'filter', :as => :filters

    has_select

    attribute :select, :as => :name, :static => true

    def compile_xml(xml, context)
      super

      @required_params = [ ]

      @params.each do |p|
        @required_params += p.names if p.required?
      end

      @name = '' if @name.nil?
      @name.gsub!(/^\//, '')

      @groups.each do |g|
        @required_params += g.required_params.collect{ |n| (@name + '/' + n).gsub(/\/+/, '/') }
      end

      @params += @groups
      @groups = nil
    end

    def apply_filters(context)
      filtered = [ ]
 
      @context.with(context) do |ctx|

        self.get_context(ctx).each do |root|
          @params.each do |param|
            @filters.each do |f|
              filtered = filtered + f.apply_filter(ctx.with_root(root))
            end
            filtered = filtered + param.apply_filters(ctx.with_root(root))
          end
        end
      end
      filtered.uniq
    end

    def apply_constraints(context)
      res = { :missing => [], :invalid => [], :valid => [], :messages => [] }
      passed = [ ]
      failed = [ ]
      @context.with(context) do |ctx|
        self.get_context(ctx).each do |root|
          @params.each do |param|
            @constraints.each do |c|
              r = c.test_constraint(ctx.with_root(root))
              passed += r[0]
              failed += r[1]
            end
            p_res = param.apply_constraints(ctx.with_root(root))
            res[:messages] += p_res[:messages]
            failed += p_res[:invalid]
            passed += p_res[:valid]
            res[:missing] += p_res[:missing]
          end
        end
      end
      res[:invalid] = failed.uniq
      res[:valid] = (passed - failed).uniq
      res[:messages].uniq!
      res[:missing] = (res[:missing] - passed).uniq
      res
    end


    def get_context(context)
      return [ context.root ] if @select.nil?
      ret = [ ]
      context.in_context do |ctx|
        ret = @select.run(ctx)
      end
      ret
    end
  end
  end
end
end
