class Bamboo::Engine::Action

  def compile_xml(xml, context)
puts "Compiling #{self.class.name}"
    @context = context.merge(xml)
    self.setup(xml)
    self
  end

  def has_actions?
    !@actions.nil? && !@actions.empty?
  end

  def self.namespace(href = nil)
    return @@namespace[self.name] if href.nil?
    @@namespace ||= { }
    @@namespace[self.name] = href
  end

  def self.attribute(e_nom, opts = { })
    @@attributes ||= { }
    @@attributes[self.name] ||= { }
    @@attributes[self.name][e_nom.to_s] = opts
    nom = (opts[:as].nil? ? e_nom : opts[:as]).to_sym
    if opts[:static]
      self.instance_eval {
        attr_reader nom.to_sym
      }
    else
      at_nom = ('@' + nom.to_s).to_sym
      self.class_eval {
        define_method(nom.to_s) { |ctx|
          v = instance_variable_get(at_nom) 
          v.nil? ? [] : v.run(ctx,false)
        }
      }
    end
  end

  def self.has_actions(t = :simple)
    @@has_actions ||= { }
    @@has_actions[self.name] = t
  end

  def self.has_actions?
    !@@has_actions.nil? && @@has_actions.has_key?(self.name)
  end

  def has_actions?
    self.class.has_actions? && !@actions.empty?
  end

  def run_actions(ctx)
    self.has_actions? ? @actions.run(ctx) : [ ]
  end

  def self.has_select(default = '.')
    @@has_select ||= { }
    @@has_select[self.name] = default
  end

  def select(ctx)
    self.class.has_select? && !@select.nil? ? @select.run(ctx,false) : [ ]
  end

  def has_select?
    self.class.has_select? && !@select.nil?
  end

  def self.has_select?
    !@@has_select.nil? && @@has_select.has_key?(self.name)
  end

   def self.at_runtime(&block)
     @@run_time ||= { }
     @@run_time[self.name] = block
   end


  def run(context, autovivify = false)
    self.run_actions(@context.merge(context))
  end

   def run(context, autovivify = false)
     ret = []
     @@run_time ||= { }
     @context.with(context) do |ctx|
       proc = @@run_time[self.class.name]
       if !proc.nil?
         ret = self.instance_eval {
           proc.call(ctx, autovivify)
         }
       end
     end
     ret
   end

protected

  def setup(xml)
    klass = self.class.name
    if @@attributes[klass]
      @@attributes[klass].each_pair do |nom, opts|
        as = "@" + (opts[:as] || nom).to_s
        self.instance_variable_set(as.to_sym, @context.attribute(opts[:namespace] || @@namespace[klass], nom.to_s, opts))
      end
    end
    if self.class.has_select?
      @select = @context.get_select(@@has_select[klass])
    end
    @actions = nil
    if @@has_actions[klass]
      case @@has_actions[klass]
        when :simple
          @actions = @context.compile_actions(xml)
        when :super
          @actions = TagLib.current_super
      end
    end
  end
end
