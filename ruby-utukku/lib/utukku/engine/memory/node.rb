require 'utukku/engine/memory/node_logic'

module Utukku::Engine::Memory
  class Node
    include Utukku::Engine::Memory::NodeLogic

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
        @vtype = [ Utukku::Engine::NS::FAB, 'string' ]
      elsif @value.is_a?(Numeric)
        @vtype = [ Utukku::Engine::NS::FAB, 'numeric' ]
      elsif @value.is_a?(TrueClass) || @value.is_a?(FalseClass)
        @vtype = [ Utukku::Engine::NS::FAB, 'boolean' ]
      end
    end

    def is_attribute?
      @is_attribute
    end

    def node_from_hash(hash)
      root = self.anon_node(hash['v'])
      root.name = hash['n']
      root.vtype = hash['t']
      if hash['c']
        hash['c'].each do |c|
          root.add_child( self.node_from_hash(c) )
        end
      end
      root
    end

    def to_paths
      hash = { }
      @children.each do |c|
        p = c.to_paths
        k = c.name
        v = c.value
        if hash[k].nil?
          hash[k] = v
        elsif hash[k].is_a?(Array)
          hash[k].push(v)
        else
          hash[k] = [ hash[k], v ]
        end
        p.each_pair do |pk, pv|
          pk = k + '/' + pk
          if hash[pk].nil?
            hash[pk] = pv
          elsif hash[pk].is_a?(Array)
            hash[pk] += pv.to_a
          else
            hash[pk] = hash[pk].to_a + pv.to_a
          end
        end
      end
      hash
    end

    def to_table_array
      acc = [ [ self.path, self.value ] ]
      self.to_paths.each_pair do |p, vs|
        vs.to_a.each do |v|
          acc.push( [ p, v ] )
        end
      end
      return acc
    end

    def axis
      @axis
    end

    def axis=(a)
      @axis = a
      self.children.each { |c| c.axis=a }
    end

    def set_attribute(k, v)
      if v.is_a?(Utukku::Engine::Memory::Node)
        v = v.clone
      else
        v = Utukku::Engine::Memory::Node.new(self.axis, self.roots, v, [], self)
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
      d = Utukku::Engine::Memory::Node.new('data', r, nil, [])
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
      op = Utukku::Engine::TagLib.find_op(@vtype, :children)
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
