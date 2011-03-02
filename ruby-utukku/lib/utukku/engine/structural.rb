#require 'nokogiri'
require 'active_support/inflector'

class Utukku::Engine::Structural < Utukku::Engine::Action

  def initialize
    @context = Utukku::Engine::Context.new
    self.init_attribute_storage

  end

  def compile_xml(xml, context = nil)
    if xml.is_a?(String)
      doc = Nokogiri::XML::Document.parse(xml)
      doc = doc.root
    elsif xml.is_a?(Nokogiri::XML::Document)
      doc = xml.root
    end

    if context.nil?
      @context = @context.merge(xml)
    else
      @context = context.merge(xml)
    end

    self.setup(xml)
  end

  def self.element(nom = nil)
    @@elements ||= { }
    @@elements[self.name] = nom unless nom.nil?
    @@elements[self.name]
  end

  def self.contains(nom, opts = { })
    ns = opts[:ns] || self.namespace
    @@structurals ||= { }
    @@structurals[self.name] ||= { }
    @@structurals[self.name][ns] ||= { }
    @@structurals[self.name][ns][nom.to_sym] = opts
    self.module_eval {
      attr_accessor((opts[:as] || nom.to_s.pluralize).to_sym)
    }
  end

  def self.contained_in(ns, nom, h = {})
    @@contained_in ||= { }

    @@contained_in[ns] ||= { }
    @@contained_in[ns][nom.to_sym] ||= { }
    @@contained_in[ns][nom.to_sym][self.namespace] ||= { }
    @@contained_in[ns][nom.to_sym][self.namespace][self.element.to_sym] = { :as => :contained }.update(h)
  end

  def self.structurals
    ret = @@structurals[self.name]
    els = self.element
    els = [ els ] unless els.is_a?(Array)

    return ret if self.element.nil?

    @@contained_in ||= { }

    return ret if @@contained_in[self.namespace].nil?

    pot = @@contained_in[self.namespace][self.element.to_sym]
    return ret if pot.nil? || pot.empty?

    pot.each_pair do |ns, noms|
      ret[ns] ||= { }
      ret[ns] = ret[ns].update(noms)
    end
    ret
  end

  def self.accepts_structural?(ns, nom)
    s = self.structurals
    in_s = (s[ns][nom.to_sym] rescue nil)
    return !in_s.nil?
  end

  def accepts_structural?(ns, nom)
    self.class.accepts_structural?(ns, nom)
  end


protected

  def init_attribute_storage
    possibilities = self.class.structurals

    if !possibilities.nil?
      possibilities.each_pair do |ns, parts|
        parts.each_pair do |nom, opts|
          snom = (opts[:as] || nom.to_s.pluralize).to_s
          as = "@" + snom
          if !self.class.respond_to?(snom.to_sym)
            self.class.module_eval {
              attr_accessor snom.to_sym
            }
          end
          if opts[:storage].nil? || opts[:storage] == :array
            self.instance_variable_set(as.to_sym, [])
          elsif opts[:storage] == :hash
            self.instance_variable_set(as.to_sym, {})
          end
        end
      end
    end
  end

  def setup(xml)
    super

    self.init_attribute_storage

    possibilities = self.class.structurals

    if !possibilities.nil?
      structs = @context.compile_structurals(xml)
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
    end
  end
end
