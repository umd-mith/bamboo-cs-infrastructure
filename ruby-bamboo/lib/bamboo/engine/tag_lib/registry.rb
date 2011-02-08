require 'singleton'

class Bamboo::Engine::TagLib::Registry
  include Singleton

  attr_accessor :handlers

  def initialize
    @handlers = { }
  end

  def handler(ns, h = nil)
    if h.nil?
      @handlers[ns]
    else
      @handlers[ns] = h
    end
  end

  def describe_namespaces(namespaces)
    conf = { }
    namespaces.each do |ns|
      h = @handlers[ns]
      next if h.nil?
      conf[ns] = {
        'mappings' => h.mappings.keys,
        'consolidations' => h.consolidations.keys,
        'reductions' => h.reductions.keys,
        'functions' => h.functions.keys,
      };
    end
    conf
  end
end
