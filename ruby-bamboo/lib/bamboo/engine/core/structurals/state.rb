module Bamboo::Engine
  module Core
  module Structurals
  class State < Bamboo::Engine::Structural
    attr_accessor :name, :transitions

    namespace Bamboo::Engine::NS::FAB

    attribute :name, :static => true

    contains 'goes-to', :as => :transitions

    def states
      @transitions.map { |t| t.state }.uniq
    end

    def select_transition(context,params)
      # we need hypthetical variables here :-/
      return nil if @context.nil?
      best_match = nil
      @context.with(context) do |ctx|
        best_match = nil
        @transitions.each do |t|
          res = t.validate_params(ctx,params)
          if res[:missing].empty? && res[:messages].empty? && res[:unknown].empty? && res[:invalid].empty?
            res[:transition] = t
          end
          if best_match.nil? || res[:score] > best_match[:score]
            best_match = res
            best_match[:transition] = t
          end
        end
      end
      return best_match
    end

    def run_pre(context)
      # do queries, denials, assertions in the order given
      ctx = context.class.new(@context, context)
      @pre_actions.run(ctx) unless @pre_actions.nil?
      return []
    end

    def run_post(context)
      # do queries, denials, assertions in the order given
      ctx = context.class.new(@context, context)
      @post_actions.run(ctx) unless @post_actions.nil?
      return []
    end
  end
  end
end
end
