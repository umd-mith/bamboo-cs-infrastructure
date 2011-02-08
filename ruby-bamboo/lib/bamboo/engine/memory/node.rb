require 'bamboo/engine/memory/node_logic'

module Bamboo::Engine::Memory
  class Node
    include Bamboo::Engine::Memory::NodeLogic

    attr_accessor :value, :name, :roots, :vtype, :attributes, :is_attribute

    def initialize(a,r,v,c,p = nil) #,f={})
      @roots = r
      @axis = a
      @children = []
      @children = @children + c if c.is_a?(Array)
      @value = v
      @vtype = nil
      @parent = p
      @name = nil
      @attributes = [ ]
      @is_attribute = false

      if @value.is_a?(String)
        @vtype = [ Bamboo::Engine::NS::FAB, 'string' ]
      elsif @value.is_a?(Numeric)
        @vtype = [ Bamboo::Engine::NS::FAB, 'numeric' ]
      elsif @value.is_a?(TrueClass) || @value.is_a?(FalseClass)
        @vtype = [ Bamboo::Engine::NS::FAB, 'boolean' ]
      end
    end

    def is_attribute?
      @is_attribute
    end

    def axis
      @axis
    end

    def axis=(a)
      @axis = a
      self.children.each { |c| c.axis=a }
    end

    def set_attribute(k, v)
      if v.is_a?(Bamboo::Engine::Memory::Node)
        v = v.clone
      else
        v = Bamboo::Engine::Memory::Node.new(self.axis, self.roots, v, [], self)
      end
      v.name = k
      v.is_attribute = true
      @attributes.delete_if{|a| a.name == k }
      @attributes << v
    end

    def get_attribute(k)
      (@attributes.select{ |a| a.name == k }.first rescue nil)
    end

    def attributes
      @attributes
    end

    def self.new_context_environment
      r = { }
      d = Bamboo::Engine::Memory::Node.new('data', r, nil, [])
      r['data'] = d
      d
    end

    def anon_node(v, t = nil)
      if v.is_a?(Array)
        n = self.class.new(self.axis, self.roots, nil, v.collect{ |vv| self.anon_node(vv, t) })
      else
        n = self.class.new(self.axis, self.roots, v, [])
        n.vtype = t unless t.nil?
      end
      n
    end

    def clone(deep = false)
      node = self.anon_node(self.value, self.vtype)
      node.name = self.name
      node.attributes = self.attributes.collect { |a| a.clone(deep) }
      node.copy(self) if deep
      node
    end

    def create_child(n,v = nil,t=nil)
      node = self.class.new(@axis, @roots, v, [], self)
      node.name = n
      node.vtype = t unless t.nil?
      @children << node
      node
    end

    def parent=(p)
      @parent = p
      @axis = p.axis
    end

    def parent
      @parent.nil? ? self : @parent
    end

    def children(n = nil)
      op = Bamboo::Engine::TagLib.find_op(@vtype, :children)
      possible = op.nil? ? @children : op.call(self)
      if n.nil?
        possible
      else
        possible.select{|c| c.name == n }
      end
    end

    def prune(c = nil)
      if c.nil?
        @children = [ ]
      elsif c.is_a?(Array)
        @children = @children - c
      else
        @children = @children - [ c ]
      end
    end

    def add_child(c)
      c.parent.prune(c) if c.parent
      c.parent = self
      c.axis = self.axis
      @children << c
    end
  end

end
