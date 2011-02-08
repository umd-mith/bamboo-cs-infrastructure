require 'nokogiri'

class Bamboo::Engine::Context

  def initialize(parent_context = nil, xml = nil)
    @parent = parent_context
    @run_time_parent = nil
    @ns = { }
    @attributes = { }
    @position = nil
    @last = nil
    @line_num = nil
    @finalizations = [ ]

    if parent_context.nil?
       if xml.nil? || (xml.root rescue nil).nil?
         roots = { }
         roots['data'] = Bamboo::Engine::Memory::Node.new('data', roots, nil, [])
         @root = roots['data']
       end
    end

    if !xml.nil?
      if xml.is_a?(self.class)
        @run_time_parent = xml
      else
        @line_num = xml.line

        parser = Bamboo::Engine::Parser.new

        xml.namespace_definitions.each do |ns|
          @ns[ns.prefix] = ns.href
        end
        begin
          @ns[''] = xml.namespace[1]
        rescue
        end

        xml.attribute_nodes.each do |attr|
          v = attr.value
          if !v.nil?
            @attributes[attr.namespace.href] ||= {}
            @attributes[attr.namespace.href][attr.name] = v
          end
        end
      end
    end
  end

  def last?
    return @last unless @last.nil?
    return @last if @run_time_parent.nil?
    return @run_time_parent.last?
  end

  def last=(l)
    @last = !!l
  end

  def line_num
    return @line_num unless @line_num.nil?
    return @parent.line_num unless @parent.nil?
    return 0
  end

  def position
    return @position unless @position.nil?
    return @position if @run_time_parent.nil?
    return @run_time_parent.position
  end

  def position=(p)
    @position = p
  end

  def merge(s = nil)
    self.class.new(self, s)
  end

  def to(t)
    self.with_root(self.root.to(t, self))
  end


  def attribute(ns, attr, popts = { })
    opts = { :static => !@run_time_parent.nil? && !self.root.nil? }.update(popts)
    value = nil
    if @attributes.nil? || @attributes[ns].nil? || @attributes[ns].empty? || @attributes[ns][attr].nil?
      if opts[:inherited]
        value = @parent.nil? ? nil : @parent.attribute(ns, attr, opts)
      end
    else
      value = @attributes[ns][attr]
    end
    if value.nil? && !opts[:default].nil?
      value = opts[:default]
    end

    if !value.nil? && value.is_a?(String)
      e = nil
      if !opts[:eval]
        if value =~ /^\{(.*)\}$/
          e = $1
        end
      else
        e = value
      end
      if !e.nil?
        p = Bamboo::Engine::Parser.new
        value = p.parse(e, self)
      else
        value = Bamboo::Engine::Parser::Literal.new(value, [ Bamboo::Engine::NS::FAB, value =~ /^\d+$/ ? 'numeric' : value =~ /^\d*\.\d+$/ || value =~ /^\d+\.\d*$/ ? 'numeric' : 'string' ])
      end
      if opts[:static]
        value = value.run(self).collect{ |v| v.value }
        if value.empty?
          value = nil
        elsif value.size == 1
          value = value.first
        end
        case opts[:type]
          when :boolean
            if value =~ /^[YyTt1]/ || value =~ /^on/i
              value = true
            else
              value = false
            end
          when :numeric
            value = value.to_f
          when :integer
            value = value.to_i
        end
      end
    end

    value
  end

  def get_select(default = nil)
    self.attribute(Bamboo::Engine::NS::FAB, 'select', { :eval => true, :static => false, :default => default })
  end

  def with_root(r)
    ctx = self.class.new(self)
    ctx.root = r
    ctx
  end

  def root
    if @root.nil?
      return @run_time_parent.nil? ? 
             ( @parent.nil? ? nil : @parent.root ) : @run_time_parent.root
    end
    @root
  end

  def root=(r)
    @root = r
  end

  def get_var(v)
    if @variables.nil? || !@variables.has_key?(v)
      if @run_time_parent.nil?
        @parent.nil? ? nil : @parent.get_var(v)
      else
        @run_time_parent.get_var(v)
      end
    else
      @variables[v]
    end
  end

  def set_var(v,vv)
    @variables ||= { }
    if @variables.has_key?(v)
      raise Bamboo::Engine::Parser::VariableAlreadyDefined.new(v)
    end
    @variables[v] = vv
  end

  def set_scoped_info(k, v)
    @scoped_info ||= { }
    @scoped_info[k] = v
  end

  def get_scoped_info(k)
    if @scoped_info.nil? || !@scoped_info.has_key?(k)
      if @run_time_parent.nil?
        @parent.nil? ? nil : @parent.get_scoped_info(k)
      else
        @run_time_parent.get_scoped_info(k)
      end
    else
      @scoped_info[k]
    end
  end

  def get_ns(n)
    return @ns[n] if !@ns.nil? && @ns.has_key?(n)
    return @parent.get_ns(n) unless @parent.nil?
    return nil
  end

  def set_ns(n,h)
    @ns ||= { }
    @ns[n] = h
  end

  def each_namespace(&block)
    if !@parent.nil?
      @parent.each_namespace do |k,v|
        yield k, v
      end
    end
    @ns.each_pair do |k,v|
       yield k, v
    end
  end

  def eval_expression(selection)
    if selection.is_a?(String)
      p = Bamboo::Engine::Parser.new
      selection = p.parse(selection, self)
    end

    if selection.nil?
      res = [ ]
    else
      # run selection against current context
      res = selection.run(self)
    end
    return res
  end

  def run(action, autovivify = false)
    action.run(self, autovivify)
  end

  def traverse_path(path, autovivify = false)
    return [ self.root ] if path.nil? || path.is_a?(Array) && path.empty?
                         
    path = [ path ] unless path.is_a?(Array)

    current = [ self.root ]

    path.each do |c|
      set = [ ]
      current.each do |cc|
        if c.is_a?(String)
          cset = cc.children(c)
        else
          cset = c.run(self.with_root(cc), autovivify)
        end
        if cset.nil? || cset.empty?
          if autovivify
            if c.is_a?(String)
              cset = [ cc.create_child(c) ]
            else
              cset = [ c.create_node(cc) ]
            end
          end
        end
        set = set + cset
      end
      current = set
    end
    return current
  end

  def set_value(p, v)
    if p.is_a?(String) || v.is_a?(String)
      parser = Bamboo::Engine::Parser.new   
      p = parser.parse(p,self) if p.is_a?(String)
      v = parser.parse(v,self) if v.is_a?(String)
    end
        
    #return [] if p.nil?
    p = [ self.root ] if p.nil?

    p = [ p ] unless p.is_a?(Array)
          
    ret = [ ]

    p.each do |pp|
      tgts = pp.is_a?(Bamboo::Engine::Memory::Node) ? [ pp ] : pp.run(self, true)
      src = nil
      if !v.nil?
        src = v.is_a?(Bamboo::Engine::Memory::Node) ? [ v ] : ( v.is_a?(Array) ? v : v.run(self) )
        src = src.select{ |s| !s.value.nil? || s.children.count > 0 }
      end 

      tgts.each do |tgt|
        tgt.prune
        if src.nil? || src.empty?
          #tgt.value = nil
          #ret << tgt
        elsif src.size == 1
          tgt.copy(src.first)
          ret << tgt
        else
          pp = tgt.parent
          nom = tgt.name
          pp.prune(pp.children(nom))
          src.each do |s|
            tgt = pp.create_child(nom,nil)
            tgt.copy(s)
            ret << tgt
          end
        end
      end
    end
    ret
  end

  def get_values(ln = nil)
    return [] if ln.nil?
    self.eval_expression(ln).collect{ |c| c.value} - [ nil ]
  end

  def merge_data(d,p = nil)
    # we have a hash or array based on root (r)
    if p.nil?
      root_context = [ self.root ]
    else
      root_context = self.traverse_path(p,true)
    end
    if root_context.size > 1
      # see if we need to prune
      new_rc = [ ]
      root_context.each do |c|
        if c.children.size == 0 && c.value.nil?
          c.parent.prune(c) if c.parent
        else
          new_rc << c
        end
      end
      if new_rc.size > 0
        raise "Unable to merge data into multiple places simultaneously"
      else
        root_context = new_rc
      end
    else
      root_context = root_context.first
    end
    if d.is_a?(Bamboo::Engine::Memory::Node)
      self.set_value(p, d)
    elsif d.is_a?(Array)
      node_name = root_context.name
      root_context = root_context.parent
      # get rid of empty children so we don't have problems later
      root_context.children.each do |c|
        if c.children.size == 0 && c.name == node_name && c.value.nil?
          c.parent.prune(c)
        end
      end
      d.each do |i|
        next if i.nil?
        if i.is_a?(Array) || i.is_a?(Hash)
          c = root_context.create_child(node_name)
          self.with_root(c).merge_data(i)
        else
          root_context.create_child(node_name, i)
        end
      end
    elsif d.is_a?(Hash)
      d.each_pair do |k,v|
        bits = k.split('.')
        c = self.with_root(root_context).traverse_path(bits,true).first
        if v.is_a?(Hash) || v.is_a?(Array) || v.is_a?(Bamboo::Engine::Memory::Node)
          self.with_root(c).merge_data(v)
        else
          c.value = v
        end
      end
    else
      c = root_context.parent.create_child(root_context.name, d)
    end
  end

  def compile_actions(xml)
    actions = Bamboo::Engine::Parser::StatementList.new
    return actions if xml.nil?

    local_ctx = self.merge(xml)
    xml.children.each do |e|
      next unless e.element?
      ns = e.namespace.href
      next unless Bamboo::Engine::TagLib.namespaces.include?(ns)
      if ns == Bamboo::Engine::NS::FAB && e.name == 'ensure'
        actions.add_ensure(local_ctx.compile_actions(e))
      elsif ns == Bamboo::Engine::NS::FAB && e.name == 'catch'
        actions.add_catch(local_ctx.compile_action(e))
      else
        actions.add_statement(local_ctx.compile_action(e)) # rescue nil)
      end
    end
    return actions
  end

  def compile_action(e)
    ns = e.namespace.href
    return unless Bamboo::Engine::TagLib.namespaces.has_key?(ns)
    Bamboo::Engine::TagLib.namespaces[ns].compile_action(e, self)
  end

  def get_action(ns, nom)
    return unless Bamboo::Engine::TagLib.namespaces.include?(ns)
    Bamboo::Engine::TagLib.namespaces[ns].get_action(nom, self)
  end

  def action_exists?(ns, nom)
    if ns == Bamboo::Engine::NS::FAB
      return true if ['ensure', 'catch'].include?(nom.to_s)
    end

    return false unless Bamboo::Engine::TagLib.namespaces.has_key?(ns)
    return Bamboo::Engine::TagLib.namespaces[ns].action_exists?(nom)
  end

  def compile_structurals(xml)
    #local_ctx = self.merge(xml)
    structs = { }
    our_ns = xml.namespace.href
    our_nom = xml.name
    xml.children.each do |e|
      next unless e.element?
      ns = e.namespace.href
      nom = e.name.to_sym
      allowed = (Bamboo::Engine::TagLib.namespaces[our_ns].structural_class(our_nom).accepts_structural?(ns, nom) rescue false)
      raise "Unknown or inappropriate tag #{ns} #{nom} in #{our_ns} #{our_nom}" unless allowed || self.action_exists?(ns, nom)
      next unless allowed
      structs[ns] ||= { }
      structs[ns][nom] ||= [ ]
      structs[ns][nom] << self.compile_structural(e)
      structs[ns][nom] -= [ nil ]
    end
    return structs
  end

  def compile_structural(e)
    ns = e.namespace.href
    return unless Bamboo::Engine::TagLib.namespaces.include?(ns)
    Bamboo::Engine::TagLib.namespaces[ns].compile_structural(e, self)
  end

  # Runs the block with a new context based on this context.  This
  # provides a new scope for variables and current nodes.
  def in_context(&block)
    ctx = self.merge
    yield ctx
  end

  # Runs the block with a new context resulting from merging this
  # context with the given context.
  def with(context, &block)
    ctx = self.merge(context)
    ret = []
    begin
      ret = yield ctx
    ensure
      ctx.clean_up
    end
    ret
  end

  def clean_up(&block)
    if block.nil?
      @finalizations.each do |f|
        f.call(self)
      end
    else
      @finalizations << block
    end
  end
    

  # Iterates through the list of items running the given block with
  # a new context with the current node set to the item.
  def with_roots(items, &block)
    idx = 1
    items.each do |i|
      ctx = self.with_root(i)
      ctx.position = idx
      ctx.last = idx == items.size
      yield ctx
      idx += 1
    end
  end

  # Runs the request filter against the current node.  The value
  # of the current node is replaced with the result of the filter.
  def run_filter(ns, name)
    handler = Bamboo::Engine::TagLib.namespaces[ns]
    return [] if handler.nil?
    handler.run_filter(self, name)
  end

  # Runs the requested constraint against the current node and returns
  # a boolean.  Returns false if no object can be found to handle the
  # specified namespace.
  def run_constraint(namespace, name)
    handler = Bamboo::Engine::TagLib.namespaces[namespace]
    return false if handler.nil?
    handler.run_constraint(self, name)
  end

end
