require 'yaml'

module Bamboo::Engine
  module Core
  module Structurals

  class StateMachine < Bamboo::Engine::Structural
    attr_accessor :states, :missing_params, :errors, :namespaces, :updated_at
    attr_accessor :state

    namespace Bamboo::Engine::NS::FAB

    contains :view, :as => :states, :storage => :hash

    has_actions

    def initialize
      @states = { }
      @context = Bamboo::Engine::Context.new
      @state = 'start'
    end

    def compile_xml(xml, context = nil)
      super

      if @states.empty?
        s = State.new
        s.name = 'start'
        @states = { 'start' => s }
      end
    end

    def clone
      YAML::load( YAML::dump( self ) )
    end

    def namespaces 
      @context.ns
    end

    def init_context(c)
      @context.root = c.root
      begin
        @actions.run(@context)
      rescue Bamboo::Engine::StateChangeException => e
        @state = e
      end
    end

    def context
      { :data => @context.root, :state => @state }
    end

    def fabulator_context
      @context
    end

    def context=(c)
      if c.is_a?(Bamboo::Engine::Context)
        @context = c
      elsif c.is_a?(Bamboo::Engine::Memory::Node)
        @context.root = c
      elsif c.is_a?(Hash)
        @context.root = c[:data]
        @state = c[:state]
      end
    end

    def run(params)
      current_state = @states[@state]
      return if current_state.nil?
      # select transition
      # possible get some errors
      # run transition, and move to new state as needed
      @context.in_context do |ctx|
        self.run_transition(current_state.select_transition(@context, params))
      end
    end

    def run_transition(best_transition)
      return if best_transition.nil? || best_transition.empty?
      current_state = @states[@state]
      t = best_transition[:transition]
      @missing_params = best_transition[:missing]
      @errors = best_transition[:messages]
      if @missing_params.empty? && @errors.empty?
        @state = t.state
        # merge valid and context
        best_transition[:valid].sort_by { |a| a.path.length }.each do |item|
          p = item.path.gsub(/^[^:]+::/, '').split('/') - [ '' ]
          n = @context.traverse_path(p, true).first
          n.prune
          n.copy(item)
        end
        # run_post of state we're leaving
        begin
          current_state.run_post(@context)
          t.run(@context)
          # run_pre for the state we're going to
          new_state = @states[@state]
          new_state.run_pre(@context) if !new_state.nil?
        rescue Bamboo::Engine::StateChangeException => e # catch state change
          new_state = @states[e]
          begin
            if !new_state.nil?
              @state = new_state.name
              new_state.run_pre(@context)
            end
          rescue Bamboo::Engine::StateChangeException => e
            new_state = @states[e] 
            retry
          end
        end
      end
    end

    def data
      @context.root
    end

    def state_names
      (@states.keys.map{ |k| @states[k].states }.flatten + @states.keys).uniq
    end
  end
  end
end
end
