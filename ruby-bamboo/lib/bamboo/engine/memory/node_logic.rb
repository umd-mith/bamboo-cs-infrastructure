module Bamboo::Engine::Memory
  module NodeLogic
      def to_s
        self.to([ Bamboo::Engine::NS::FAB, 'string' ]).value
      end

      def to_h
        r = { }
        #  :attributes => { },

        r[:name] = self.name unless self.name.nil?
        cs = self.children.collect { |c| c.to_h }
        r[:children] = cs unless cs.empty?
        r[:value] = self.value unless self.value.nil?
        r[:type] = self.vtype.join('') unless self.vtype.nil?
        r[:attributes] = { }
        self.attributes.each do |a|
          r[:attributes][a.name] = a.value
        end
        r
      end

      def to(t, ctx = nil)
        if @vtype.nil? || t.nil?
          return self.anon_node(self.value, self.vtype)
        end
        if self.vtype.join('') == t.join('')
          return self
        end
        # see if there's a path between @vtype and t
        #   if so, do the conversion
        #   otherwise, return nil
        path = Bamboo::Engine::TagLib.type_path(self.vtype, t)
        return self.anon_node(nil,nil) if path.empty?
        v = self
        ctx = Bamboo::Engine::Context.new if ctx.nil?
        path.each do |p|
          vv = nil
          begin
            vv = p.convert(ctx.with_root(v))
          rescue => e
            raise "Converting to #{t[1]} raised #{e}"
          end
          if vv.is_a?(Bamboo::Engine::Memory::Node)
            v = vv
          else
            v = self.anon_node(vv)
          end
        end
        v.vtype = t
        return v
      end

      def in_context(&block)
          yield
      end

      def path
        if self.parent.nil? || self.parent == self
          return ''
        else
          return self.parent.path + '/' + (self.is_attribute? ? '@' : '') + self.name
        end
      end

      def copy(c)
        self.value = c.value
        self.vtype = c.vtype
        # TODO: attributes
        
        c.attributes.each do |a|
          self.set_attribute(a.name,a.value)
        end
        c.children.each do |cc|
          n = self.create_child(cc.name, cc.value)
          n.copy(cc)
        end
      end

      def empty?
        self.value.nil? && self.children.empty?
      end
 
      def root(a = nil)
        if(a.nil? || a == '')
          a = self.axis
        end
        if a.nil? || a == '' || self.roots[a].nil?
          p = self
          while !p.parent.nil? && p.parent != self
            p = p.parent
          end
          self.roots[a] = p unless a.nil? || a == ''
          return p
        else
          self.roots[a.nil? ? self.axis : a]
        end
      end   
  end
end
