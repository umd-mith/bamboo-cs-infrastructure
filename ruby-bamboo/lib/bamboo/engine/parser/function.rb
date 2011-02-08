require 'bamboo/engine/constant_iterator'

class Bamboo::Engine::Parser::Function
  def initialize(ctx, nom, args)
    nom.gsub(/\s+/, '')
    bits = nom.split(/:/, 2)
    @ns = ctx.get_ns(bits[0])
    @name = bits[1]
    if @name =~ /^(.+)\*$/
      @name = "consolidation:#{$1}"
    end
    @args = args
    @ctx = ctx
  end

  def expr_type(context)
    return [ Bamboo::Engine::NS::FAB, 'boolean' ] if @name =~ /\?$/
    klass = Bamboo::Engine::TagLib.namespaces[@ns]
    (klass.function_return_type(@name) rescue nil)
  end

  def run(context, autovivify = false)
    klass = Bamboo::Engine::TagLib.namespaces[@ns]
    return [] if klass.nil?
    ctx = @ctx.merge(context)
    ret = klass.run_function(
      ctx, @name, @args.run(ctx)
    )
    if @name =~ /\?$/
      ret = ret.collect{ |v| v.to([Bamboo::Engine::NS::FAB, 'boolean']) }
    end
    ret
  end

  def async(context, av, callbacks)
    klass = Bamboo::Engine::TagLib.namespaces[@ns]
    return [] if klass.nil?
    ctx = @ctx.merge(context)
    ret = klass.function_to_iterator(
      ctx, @name, @args
    )
    if @name =~ /\?$/
      ret = Bamboo::Engine::MapIterator.new(
        ret, proc { |v| v.to([Bamboo::Engine::NS::FAB, 'boolean']) }
      )
    end
    ret.async(callbacks)
  end
end

class Bamboo::Engine::Parser::List
  def initialize(args)
    @args = args
  end

  def run(context, autovivify = false)
    @args.collect{ |arg| arg.run(context, autovivify).flatten }
  end

  def async(context, av, callbacks)
    accs = [ ]
    subs = [ ]
    dones = 0
    @args.size.times do |i|
      accs[i] = [ ]
      subs.push(@args[i].async(context, av, {
        :next => proc { |v| accs[i].push(v) },
        :done => proc {     dones += 1;
          if dones >= @args.size
            callbacks[:next].call(accs)
            callbacks[:done].call()
          end
        }
      }))
    end
    proc { subs.each { |s| s.call() } }
  end
end

class Bamboo::Engine::Parser::Tuple
  def initialize(args)
    @args = args
  end

  def run(context, autovivify = false)
    items = @args.collect{ |arg| arg.run(context, autovivify).flatten }.flatten
    ret = context.root.anon_node(nil, [ Bamboo::Engine::NS::FAB, 'tuple' ])
    ret.value = items
    ret.vtype = [ Bamboo::Engine::NS::FAB, 'tuple' ]
    ret.set_attribute('size', items.size)
    [ ret ]
  end
end
