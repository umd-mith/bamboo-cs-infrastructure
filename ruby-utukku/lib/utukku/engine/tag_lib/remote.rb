require 'utukku/engine/null_iterator'
require 'utukku/client/flow_iterator'

class Utukku::Engine::TagLib::Remote
  attr_accessor :client

  def initialize(ns, config)
    @ns = ns
    @functions = config['functions'].inject({}) { |s,f| s[f] = true; s }
    @reductions = config['reductions'].inject({}) { |s,f| s[f] = true; s }
    @consolidations = config['consolidations'].inject({}) { |s,f| s[f] = true; s }
    @mappings = config['mappings'].inject({}) { |s,f| s[f] = true; s }
  end

  def function_to_iterator(nom, args)
    return Utukku::Engine::NullIterator.new unless self.client

    iterators = { }
    vars = [ ]

    if nom =~ /^(.*)\*$/ && @consolidations[$1] || @reductions[nom] || @mappings[nom]
      iterators['arg'] = args.length > 1 ? Utukku::Engine::UnionIterator.new( args ) : args.first
      vars = [ 'arg' ]
    elsif @functions[nom]
      i = 0
      args.each do |a|
        iterators["arg_#{i}"] = args[i]
        vars += [ "arg_#{i}" ]
        i += 1
      end
    else
      return Utukku::Engine::NullIterator.new
    end

    expression = 'x:' + nom + '(' +
      (vars.empty? ? '' : '$') + vars.join(', $') + ')'
    Utukku::Client::FlowIterator.new(@client, expression, { 'x' => @ns }, iterators)
  end
end
