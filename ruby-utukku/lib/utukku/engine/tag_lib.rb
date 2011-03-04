require 'utukku/engine'

class Utukku::Engine::TagLib

  require 'utukku/engine/tag_lib/presentations'
  require 'utukku/engine/tag_lib/type'
  require 'utukku/engine/tag_lib/transformations'
  require 'utukku/engine/tag_lib/registry'

  require 'utukku/engine/iterator'
  require 'utukku/engine/null_iterator'
  require 'utukku/engine/map_iterator'
  require 'utukku/engine/union_iterator'
  require 'utukku/engine/reduction_iterator'
  require 'utukku/engine/accumulator_iterator'

  @@action_descriptions = {}
  @@structural_descriptions = {}
  @@structural_classes = {}
  @@function_descriptions = {}
  @@function_args = { }
  @@functions = { }
  @@mappings = { }
  @@reductions = { }
  @@consolidations = { }
  @@namespaces = {}
  @@attributes = [ ]
  @@last_description = nil
  @@presentations = { }
  @@types = { }
  @@axes = { }

  def self.last_description
    @@last_description
  end
  def self.namespaces
    Utukku::Engine::TagLib::Registry.instance.handlers
    #@@namespaces
  end
  def self.action_descriptions
    @@action_descriptions
  end
  def self.structural_descriptions
    @@structural_descriptions
  end
  def self.structural_classes
    @@structural_classes
  end
  def self.function_description
    @@function_description
  end
  def self.function_args
    @@function_args
  end
  def self.attributes
    @@attributes
  end
  def self.types
    @@types
  end
  def self.axes
    @@axes
  end
  def self.presentations
    @@presentations
  end

  def self.functions
    @@functions
  end
  def self.mappings
    @@mappings
  end
  def self.consolidations
    @@consolidations
  end
  def self.reductions
    @@reductions
  end

  def self.last_description=(x)
    @@last_description = x
  end
  def self.namespaces=(x)
    @@namespaces = x
  end
  def self.action_descriptions=(x)
    @@action_descriptions = x
  end
  def self.structural_descriptions=(x)
    @@structural_descriptions = x
  end
  def self.structural_classes=(x)
    @@structural_classes = x
  end
  def self.function_description=(x)
    @@function_description = x
  end
  def self.function_args=(x)
    @@function_args = x
  end
  def self.attributes=(x)
    @@attributes = x
  end
  def self.types=(x)
    @@types = x
  end
  def self.axes=(x)
    @@axes = x
  end
  def self.presentations=(x)
    @@presentations = x
  end

  def functions
    Utukku::Engine::TagLib.functions[self.class.name] ||= { }
  end
  def mappings
    Utukku::Engine::TagLib.mappings[self.class.name] ||= { }
  end
  def consolidations
    Utukku::Engine::TagLib.consolidations[self.class.name] ||= { }
  end
  def reductions
    Utukku::Engine::TagLib.reductions[self.class.name] ||= { }
  end

  def structural_class(nom)
    Utukku::Engine::TagLib.structural_classes[self.class.name][nom.to_sym]
  end

  def self.inherited(base)
    base.extend(ClassMethods)
  end

  def self.type_handler(t)
    (@@types[t[0]][t[1].to_sym] rescue nil)
  end

  def self.find_op(t,o)
    ( self.type_handler(t).get_method(t[0] + o.to_s.upcase) rescue nil )
  end

  # returns nil if no common type can be found
  def self.unify_types(ts)
    # breadth-first search from all ts to find common type that
    # we can convert to.  We have to check all levels each time
    # in case one of the initial types becomes a common type across
    # all ts

    return nil if ts.empty? || ts.include?(nil)

    # now group by types since we only need one of each type for unification
    grouped = { }
    ts.each do |t|
      t = t.vtype.collect{ |i| i.to_s} unless t.is_a?(Array)
      grouped[t.join('')] = t
    end

    grouped = grouped.values

    return grouped.first if grouped.size == 1
   
    # now we unify based on the first two and then adding one each time
    # until we unify all of them
    t1 = grouped.pop
    t2 = grouped.pop
    t1_obj = self.type_handler(t1)
    ut = t1_obj.unify_with_type(t2)
    return nil if ut.nil?
    self.unify_types([ ut[:t] ] + grouped)
  end

  def self.type_path(from, to)
    return [] if from.nil? || to.nil? || from.join('') == to.join('')
    from_obj = self.type_handler(from)
    return [] if from_obj.nil?
    return from_obj.build_conversion_to(to)
  end

  def self.with_super(s, &block)
    @@super ||= []  # not thread safe :-/
    @@super.unshift(s)
    yield
    @@super.shift
  end

  def self.current_super
    return nil if @@super.nil? || @@super.empty?
    return @@super.first
  end

  def compile_action(e, c)
    if self.class.method_defined? "action:#{e.name}"
      send "action:#{e.name}", e, c   #.merge(e)
    end
  end

  def compile_structural(e, c)
    if self.class.method_defined? "structural:#{e.name}"
      send "structural:#{e.name}", e, c
    end
  end

  def action_exists?(nom)
    self.respond_to?("action:#{nom.to_s}")
  end

  def function_to_iterator(context, nom, args)
    unless args.is_a?(Array)
      args = [ args ] - [ nil ]
    end
    ret = Utukku::Engine::NullIterator.new
    case self.function_run_type(nom)
    when :mapping
      args = args.flatten #collect{ |a| a.run(context) }
      ret = Utukku::Engine::MapIterator.new(
        (args.size > 1 ? Utukku::Engine::UnionIterator.new(args) :
        args.size == 1 ? args.first :
        Utukku::Engine::NullIterator.new)) do |a|
           send "fctn:#{nom}", context, a 
        end
    when :reduction
      args = args.flatten #.collect{ |a| a.run(context) }.flatten
      acc = [ ]
      ret = Utukku::Engine::ReductionIterator.new(
        (args.size > 1 ? Utukku::Engine::UnionIterator.new(args) :
        args.size == 1 ? args.first :
        Utukku::Engine::NullIterator.new),
        { :next => proc { |v| acc.push(v) },
          :done => proc { send "fctn:#{nom}", context, acc }
        }
      )
    when :consolidation
      args = args.flatten #collect{ |a| a.run(context) }
      acc = [ ]
      fctn = nil
      if respond_to?("fctn:#{nom}")
        fctn = "fctn:#{nom}"
      elsif nom =~ /^consolidation:(.*)$/
        fctn = "fctn:#{$1}"
      end
      ret = fctn.nil? ? Utukku::Engine::NullIterator.new :
          Utukku::Engine::ReductionIterator.new(
            (args.size > 1 ? Utukku::Engine::UnionIterator.new(args) :
            args.size == 1 ? args.first :
            Utukku::Engine::NullIterator.new),
            { :next => proc { |v| acc.push(v) },
              :done => proc { send "fctn:#{nom}", context, acc }
            }
          )
    else
 ## TODO: fix this for functions
      args = args.flatten
      ret = Utukku::Engine::AccumulatorIterator.new(args) do |args2|
              self.run_function(context, nom, args2)
            end
    end
    return ret
  end

  def run_function(context, nom, args, depth=0)
    ret = []

    begin
      case self.function_run_type(nom)
      when :mapping
        ret = args.to_a.flatten.collect { |a| send "fctn:#{nom}", context, a }
      when :reduction
        ret = send "fctn:#{nom}", context, args.to_a.flatten
      when :consolidation
        if respond_to?("fctn:#{nom}")
          ret = send "fctn:#{nom}", context, args.to_a.flatten
        elsif nom =~ /^consolidation:(.*)$/
          ret = send "fctn:#{$1}", context, args.to_a.flatten
        else
          ret = [ ]
        end
      else
        ret = send "fctn:#{nom}", context, args
      end
    rescue => e
      raise "function #{nom} raised #{e}"
    end
    unless ret.is_a?(Utukku::Engine::Iterator)
      ret = [ ret ] unless ret.is_a?(Array)
      ret = Utukku::Engine::ConstantIterator.new(ret.flatten)
    end

    ret = ret.collect{ |r| 
      if r.is_a?(Utukku::Engine::Memory::Node) 
        r 
      elsif r.is_a?(Hash)
        rr = context.root.anon_node(nil, nil)
        r.each_pair do |k,v|
          v = [ v ] unless v.is_a?(Array)
          v.each do |vv|
            rrr = rr.anon_node(vv)
            rrr.name = k
            rr.add_child(rrr)
          end
        end
        rr
      else
        rt = self.function_return_type(nom)
        if rt.nil?
          context.root.anon_node(r) #, self.function_return_type(nom))
        else
          context.root.anon_node(r,rt)
        end
      end
    }
    ret.to_a
  end

  def function_return_type(name)
    (self.function_descriptions[name.to_sym][:returns] rescue nil)
  end

  def function_run_scaling(name)
    (self.function_descriptions[name.to_sym][:scaling] rescue nil)
  end

  def function_run_type(name)
    r = (self.function_descriptions[name.to_sym][:type] rescue nil)
    if r.nil? && !self.function_descriptions.has_key?(name.to_sym)
      if name =~ /^consolidation:(.*)/
        if function_run_scaling($1) != :flat
          return :consolidation
        end
      end
    end
    r
  end

  def function_args
    @function_args ||= { }
  end

  def run_filter(context, nom)
    send "filter:#{nom}", context
  end

  def run_constraint(context, nom)
    context = [ context ] unless context.is_a?(Array)
    paths = [ [], [] ]
    context.each do |c|
      p = send("constraint:#{nom}", c) 
      paths[0] += p[0]
      paths[1] += p[1]
    end
    return [ (paths[0] - paths[1]).uniq, paths[1].uniq ]
  end

  def action_descriptions(hash=nil)
    self.class.action_descriptions hash
  end

  def function_descriptions(hash=nil)
    self.class.function_descriptions hash
  end

  def function_args(hash=nil)
    self.class.function_args hash
  end

  def presentation
    self.class.presentation
  end

  module ClassMethods
    def inherited(subclass)
      subclass.action_descriptions.reverse_merge! self.action_descriptions
      subclass.function_descriptions.reverse_merge! self.function_descriptions
      super
    end
    
    def action_descriptions(hash = nil)
      Utukku::Engine::TagLib.action_descriptions[self.name] ||= (hash ||{})
    end

    def function_descriptions(hash = nil)
      Utukku::Engine::TagLib.action_descriptions[self.name] ||= (hash ||{})
    end
  
    def register_namespace(ns)
      Utukku::Engine::TagLib::Registry.instance.handler(ns, self.new)
    end

    def namespace(ns = nil)
      return @namespace if ns.nil?
      @namespace = ns
      Utukku::Engine::TagLib::Registry.instance.handler(ns, self.new)
    end

    def presentation
      Utukku::Engine::TagLib.presentations[self.name] ||= Utukku::Engine::TagLib::Presentations.new
    end

    def register_attribute(a, options = {})
      ns = nil
      Utukku::Engine::TagLib.namespaces.each_pair do |k,v|
        if v.is_a?(self)
          ns = k
        end
      end
      Utukku::Engine::TagLib.attributes << [ ns, a, options ]
    end

    def get_type(nom)
      ns = nil
      Utukku::Engine::TagLib.namespaces.each_pair do |k,v|
        if v.is_a?(self)
          ns = k
        end
      end
      Utukku::Engine::TagLib.types[ns][nom.to_sym]
    end

    def has_type(nom, &block)
      ns = nil
      Utukku::Engine::TagLib.namespaces.each_pair do |k,v|
        if v.is_a?(self)
          ns = k
        end
      end
      Utukku::Engine::TagLib.types[ns] ||= {}
      Utukku::Engine::TagLib.types[ns][nom.to_sym] ||= Utukku::Engine::TagLib::Type.new([ns, nom.to_sym])

      if block
        Utukku::Engine::TagLib.types[ns][nom.to_sym].instance_eval &block
      end

      mapping nom do |ctx, i|
        ctx.with_root(i).to([ ns, nom.to_s ]).root
      end
    end

    def axis(nom, &block)
      Utukku::Engine::TagLib.axes[nom] = block
    end

    def namespaces
      Utukku::Engine::TagLib.namespaces
    end

    def desc(text)
      Utukku::Engine::TagLib.last_description = RedCloth.new(Util.strip_leading_whitespace(text)).to_html
    end
    
    def action(name, klass = nil, &block)
      self.action_descriptions[name.to_sym] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      Utukku::Engine::TagLib.last_description = nil
      if block
        define_method("action:#{name.to_s}", block)
      elsif !klass.nil?
        Utukku::Engine::TagLib.structural_classes[self.name] ||= {}
        Utukku::Engine::TagLib.structural_classes[self.name][name.to_sym] = klass
        action(name) { |e,c|
          r = klass.new
          r.compile_xml(e,c)
          r
        }
      end
    end

    def structural(name, klass = nil, &block)
      self.structural_descriptions[name.to_sym] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      Utukku::Engine::TagLib.last_description = nil
      if block
        define_method("structural:#{name.to_s}", block)
      elsif !klass.nil?
        structural(name) { |e,c|
          r = klass.new
          r.compile_xml(e,c)
          r
        }
        Utukku::Engine::TagLib.structural_classes[self.name] ||= {}
        Utukku::Engine::TagLib.structural_classes[self.name][name.to_sym] = klass
      end
    end


    def function(name, options = { }, &block)
      Utukku::Engine::TagLib.functions[self.name] ||= {}
      Utukku::Engine::TagLib.functions[self.name][name.to_sym] = { }
      #self.function_descriptions[name.to_sym] = { :returns => returns, :takes => takes }
      self.function_descriptions[name.to_sym][:description] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      #self.function_args[name] = { :return => returns, :takes => takes }
      Utukku::Engine::TagLib.last_description = nil
      if block
        define_method("fctn:#{name}", &block)
      else
        parser = Utukku::Engine::Parser.new
        context = Utukku::Engine::Context.new
        if options[:namespaces]
          options[:namespaces].each_pair do |p, ns|
            context.set_ns(p.to_s, ns)
          end
        end
        context.set_ns('my', self.namespace)
        expr = parser.parse(options[:code], context)
        define_method("fctn:#{name}", proc { |ctx, args|
          res = []
          context.with(ctx) do |c|
            args.size.times do |i|
              c.set_var((i+1).to_s, args[i])
            end
            res = expr.run(c)
          end
          res 
        })
      end
    end

    def reduction(name, opts = {}, &block)
      Utukku::Engine::TagLib.reductions[self.name] ||= {}
      Utukku::Engine::TagLib.reductions[self.name][name.to_sym] = { }
      self.function_descriptions[name.to_sym] = { :type => :reduction }.merge(opts)
      self.function_descriptions[name.to_sym][:description] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      Utukku::Engine::TagLib.last_description = nil
      if block
        define_method("fctn:#{name}", &block)
      else
      end
      cons = self.function_descriptions[name.to_sym][:consolidation]
      if !cons.nil?
        Utukku::Engine::TagLib.last_description = self.function_descriptions[name.to_sym][:description]
        consolidation name do |ctx, args|
          send "fctn:#{cons}", ctx, args
        end
      end
    end

    def consolidation(name, opts = {}, &block)
      Utukku::Engine::TagLib.consolidations[self.name] ||= {}
      Utukku::Engine::TagLib.consolidations[self.name][name.to_sym] = { }
      self.function_descriptions[name.to_sym] = { :type => :consolidation }.merge(opts)
      self.function_descriptions[name.to_sym][:description] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      Utukku::Engine::TagLib.last_description = nil
      define_method("fctn:consolidation:#{name}", &block)
    end

    def mapping(name, opts = {}, &block)
      name = name.to_sym
      Utukku::Engine::TagLib.mappings[self.name] ||= {}
      Utukku::Engine::TagLib.mappings[self.name][name] = { }
      self.function_descriptions[name] = { :type => :mapping }.merge(opts)
      self.function_descriptions[name][:description] = Utukku::Engine::TagLib.last_description if Utukku::Engine::TagLib.last_description
      Utukku::Engine::TagLib.last_description = nil
      if block
        define_method("fctn:#{name.to_s}", &block)
      else
        parser = Utukku::Engine::Parser.new
        context = Utukku::Engine::Context.new
        if opts[:namespaces]
          opts[:namespaces].each_pair do |p, ns|
            context.set_ns(p.to_s, ns)
          end
        end
        context.set_ns('my', self.namespace)
        expr = parser.parse(opts[:code], context)
        define_method("fctn:#{name.to_s}", proc { |ctx, arg|
          res = [ ]
          context.with(ctx) do |c|
            c.set_var("1", arg)
            res = expr.run(c)
          end
          res 
        })
      end
    end

#    def function_decl(name, expr, ns)
#      parser = Utukku::Engine::Parser.new
#      fctn_body = parser.parse(expr, ns)
#
#      function name do |ctx, args, ns|
#        res = nil
#        ctx.in_context do
#          args.size.times do |i|
#            ctx.set_var((i+1).to_s, args[i])
#          end
#          res = fctn_body.run(ctx)
#        end
#        res
#      end
#    end

    def filter(name, &block)
      define_method("filter:#{name}", &block)
    end

    def constraint(name, &block)
      define_method("constraint:#{name}", &block)
    end

    def presentations(&block)
      self.presentation.instance_eval &block
    end
  end
   
  module Util
    def self.strip_leading_whitespace(text)
      text = text.dup
      text.gsub!("\t", "  ")
      lines = text.split("\n")
      leading = lines.map do |line|
        unless line =~ /^\s*$/
           line.match(/^(\s*)/)[0].length
        else
          nil
        end
      end.compact.min
      lines.inject([]) {|ary, line| ary << line.sub(/^[ ]{#{leading}}/, "")}.join("\n")
    end      
  end
end
