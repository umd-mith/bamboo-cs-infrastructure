module Utukku::Engine
  module Core
  module Structurals
  class Parameter < Utukku::Engine::Structural
    attr_accessor :name

    namespace Utukku::Engine::NS::FAB

    attribute :name, :eval => false, :static => true
    attribute :required, :static => true, :default => 'false'

    contains :constraint
    contains :filter
    contains :value, :as => :constraints

    def required?
      @required
    end

    def param_names
      [ @name ]
    end

    def names
      [ @name ]
    end

    def compile_xml(xml, context)
      super

      case @required.downcase
        when 'yes'
          @required = true
        when 'true'
          @required = true
        when 'no'
          @required = false
        when 'false'
          @required = false
      end
    end

    def get_context(context)
      context = [ context ] unless context.is_a?(Array)
      context.collect{ |c| c.traverse_path(@name) }.flatten
    end

    def apply_filters(context)
      filtered = [ ]
      @context.with(context) do |ctx|
        @filters.each do |f|
          self.get_context(ctx).each do |cc|
            filtered = filtered + f.run(ctx.with_root(cc))
          end
        end
      end
      filtered
    end

    def apply_constraints(context)
      res = { :missing => [], :invalid => [], :valid => [], :messages => [] }
      ctx = @context.merge(context)
      items = self.get_context(ctx)
      #name = context.attribute(Utukku::Engine::NS::FAB, 'name')
      if items.empty?
        if required?
          res[:missing] = [ (ctx.root.path + '/' + @name).gsub(/\/+/, '/') ]
        end
      elsif @constraints.empty? # make sure something exists
        res[:valid] = items
      elsif @all_constraints
        @constraints.each do |c|
          items.each do |item|
            r = c.test_constraint(ctx.with_root(i))
            res[:valid] += r[0]
            if !r[1].empty?
              res[:invalid] += r[1]
              res[:messages] += r[1].collect{ |i| c.error_message(i) }
            end
          end
        end
      else
        items.each do |item|
          passed = @constraints.select {|c| c.test_constraint(ctx.with_root(item))[1].empty? }
          if passed.empty?
            res[:invalid] << item
            res[:messages] += @constraints.collect { |c| c.error_message(item) }
          else
            res[:valid] << item
          end
        end
      end

      return res
    end

  end
  end
end
end
