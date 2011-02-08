module Bamboo::Engine
  module Core
  module Structurals
  class Transition < Bamboo::Engine::Structural
    attr_accessor :state, :validations, :tags

    namespace Bamboo::Engine::NS::FAB

    attribute :view, :as => :state, :static => true
    #attribute :tag,  :as => :ltags,  :static => true, :default => ''

    contains :params, :as => :params

    has_actions

    def param_names
      (@params.collect{|w| w.param_names}.flatten).uniq
    end

    def validate_params(context,params)
      ctx = @context.merge(context)
      my_params = params

      param_context = Bamboo::Engine::Memory::Node.new(
        'ext',
        ctx.root.roots,
        nil,
        []
      )
      ctx.root.roots['ext'] = param_context
      p_ctx = ctx.with_root(param_context)
      p_ctx.merge_data(my_params)

      if @select.nil?
        self.apply_filters(p_ctx)
      else
        @select.run(p_ctx).each{ |c| self.apply_filters(p_ctx.with_root(c)) }
      end

      res = {
        :unknown => [ ],
        :valid => [ ],
        :invalid => [ ],
        :missing => [ ],
        :messages => [ ],
      }

      if @select.nil?
        rr = self.apply_constraints(p_ctx)
        res[:invalid] += rr[:invalid]
        res[:valid] += rr[:valid]
        res[:unknown] += rr[:unknown]
        res[:messages] += rr[:messages]
      else
        @select.run(p_ctx).each do |c|
          rr = self.apply_constraints(p_ctx.with_root(c))
          res[:invalid] += rr[:invalid]
          res[:valid] += rr[:valid]
          res[:unknown] += rr[:unknown]
          res[:messages] += rr[:messages]
        end
      end

      res[:unknown] = [ ]

      res[:invalid].uniq!
      res[:invalid].each do |k|
        res[:valid].delete(k.path)
        res[:unknown].delete(k.path)
      end
      #res[:unknown] = res[:unknown].collect{|k| @select + k}
      res[:unknown].each do |k|
        res[:valid].delete(k)
      end

      res[:score] = (res[:valid].size+1)*(params.size) /
                    (res[:missing].size + 1) /
                    (res[:invalid].size + 1) /
                    (res[:unknown].size + 1)
      return res
    end

    def apply_filters(ctx)
      @params.collect { |p|
        p.apply_filters(ctx)
      }.flatten
    end

    def apply_constraints(ctx)
      invalid = [ ]
      missing = [ ]
      valid = [ ]
      msgs = [ ]
      @params.each do |p|
        res = p.apply_constraints(ctx)
        invalid = invalid + res[:invalid]
        missing = missing + res[:missing]
        valid = valid + res[:valid]
        msgs = msgs + res[:messages]
      end
      return { :missing => missing, :invalid => invalid, :valid => valid, :messages => msgs, :unknown => [ ] }
    end

    def run(context)
      # do queries, denials, assertions in the order given
      @actions.run(@context.merge(context))
      return []
    end
  end
  end
end
end
