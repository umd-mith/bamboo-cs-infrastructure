require 'utukku/engine/tag_lib'

class Utukku::Engine::Lib::Structurals::Lib < Utukku::Engine::Structural
  namespace Utukku::Engine::NS::LIB

  element :library
    
  attribute :ns, :static => true

  contains :action, :storage => :hash, :key => :name, :delayable => true
  contains :structural, :storage => :hash, :key => :name, :delayable => true
  contains :function, :storage => :hash, :key => :name, :delayable => true
  contains :mapping, :storage => :hash, :key => :name, :delayable => true
  contains :reduction, :storage => :hash, :key => :name, :delayable => true
  contains :consolidation, :storage => :hash, :key => :name, :delayable => true
  contains :template, :storage => :hash, :key => :name, :delayable => true
  contains :type, :storage => :hash, :key => :name, :delayable => true
  contains :filter, :storage => :hash, :key => :name, :delayable => true
  contains :constraint, :storage => :hash, :key => :name, :delayable => true
  contains :format, :storage => :hash, :key => :name
  contains :transform

  def presentation
    @presentations ||= Utukku::Engine::TagLib::Presentations.new
  end

  def register_library
    Utukku::Engine::TagLib.namespaces[self.ns] = self
  end

  def compile_action(e, context)
    name = e.name
    return nil unless @actions.has_key?(name)
    @actions[name].compile_action(e, context)
  end

  def get_action(nom, context)
    return nil unless self.action_exists?(nom)
    @actions[nom]
  end

  def action_exists?(nom)
    @actions.has_key?(nom.to_s)
  end

  def run_function(context, nom, args)
    # look for a function/mapping/consolidation
    # then pass along to any objects in @contained

    fctn = nil
    fctn_type = nil

    if nom =~ /^(.*)\*$/
      cnom = $1
      if !@consolidations[cnom].nil?
        fctn = @consolidations[cnom]
        fctn_type = :reduction
      end
    else
      if @consolidations.has_key?(nom)
        fctn = @reductions[nom]
        fctn_type = :reduction
      end
      if fctn.nil?
        fctn = @mappings[nom]
        fctn_type = :mapping
      end
      if fctn.nil?
        fctn = @functions[nom]
        fctn_type = :function
      end
      if fctn.nil?
        fctn = @reductions[nom]
        fctn_type = :reduction
      end
      if fctn.nil?
        fctn = @templates[nom]
        fctn_type = :function
      end
    end

    if !fctn.nil?
      res = [ ]
      context.in_context do |ctx|
        args = args.flatten
        case fctn_type
          when :function
            args.size.times do |i|
              ctx.set_var((i+1).to_s, args[i])
            end
            ctx.set_var('0', args)
            res = fctn.run(ctx)
          when :mapping
            res = args.collect{ |a| fctn.run(ctx.with_root(a)) }.flatten
          when :reduction
            ctx.set_var('0', args.flatten)
            res = fctn.run(ctx)
        end
      end
      return res
    end

    return [] if @contained.nil?

    @contained.each do |c|
      ret = c.run_function(context, nom, args)
      return ret unless ret.nil? || ret.empty?
    end
    []
  end   

  def function_return_type(name)
    (self.function_descriptions[name][:returns] rescue nil)
  end

  def function_args
    @function_args ||= { }
  end

  def run_filter(context, nom)
    return if @contained.nil?
    @contained.each do |c|
      ret = c.run_filter(context, nom)
      return ret unless ret.nil?
    end
    nil
  end

  def run_constraint(context, nom)
    return if @contained.nil?
    @contained.each do |c|
      ret = c.run_constraint(context, nom)
      return ret unless ret.nil?
    end
    false
  end

protected

  def setup(xml)
    xml.attribute_nodes.each do |attr|
      @ns = attr.value if attr.namespace.href == Utukku::Engine::NS::LIB && attr.name == 'ns'
    end
    #@ns = xml.attribute_with_ns(Utukku::Engine::NS::LIB, 'ns').value
    Utukku::Engine::TagLib.namespaces[@ns] = self

    self.init_attribute_storage
  
    possibilities = self.class.structurals

    if !possibilities.nil?
    
      our_ns = xml.namespace.href
      our_nom = xml.name
      delayed = [ ]
      xml.children.select{|e| e.element? }.each{ |e| delayed << e }
      while !delayed.empty?
        structs = { }
        new_delayed = [ ]
        delayed.each do |e|
          ns = e.namespace.href
          nom = e.name.to_sym
          allowed = (Utukku::Engine::TagLib.namespaces[our_ns].structural_class(our_nom).accepts_structural?(ns, nom) rescue false)
          next unless allowed
          structs[ns] ||= { }
          structs[ns][nom] ||= [ ]
          begin
            structs[ns][nom] << @context.compile_structural(e)
          rescue => ee
            new_delayed << e
          end
          structs[ns][nom] -= [ nil ]
        end

        structs.each_pair do |ns, parts|
          next unless possibilities[ns]
          parts.each_pair do |nom, objs|
            next unless possibilities[ns][nom]
            opts = possibilities[ns][nom]
            as = "@" + (opts[:as] || nom.to_s.pluralize).to_s
            if opts[:storage].nil? || opts[:storage] == :array
              self.instance_variable_set(as.to_sym, self.instance_variable_get(as.to_sym) + objs)
            else
              tgt = self.instance_variable_get(as.to_sym)
              objs.each do |obj|
                tgt[obj.send(opts[:key] || :name)] = obj
              end
            end
          end
        end

        if (new_delayed - delayed).empty? && (delayed - new_delayed).empty?
          delayed = []
        else
          delayed = new_delayed
        end
      end
    end

  end
end
