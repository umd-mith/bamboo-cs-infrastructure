class Utukku::Engine::AccumulatorIterator < Utukku::Engine::Iterator

  def initialize(args, &block)
    @args = args.collect{ |a| a.is_a?(Utukku::Engine::Iterator) ? a : Utukku::Engine::ConstantIterator.new(a) }
    @proc = block
  end

  def build_async(callbacks)
    accs = [ ]
    done = [ ]
    procs = [ ]
    @args.size.times do |i|
      accs[i] = [ ]
      done = 0
      procs[i] = @args[i].build_async({
        :next => proc { |v| accs[i].push(v) },
        :done => proc { done += 1
          if done >= @args.size
            r = @proc.call(accs)
            r = Utukku::Engine::ConstantIterator.new(r) if r.is_a?(Array)
            if r.is_a?(Utukku::Engine::Iterator)
              r.async(callbacks)
            else
              callbacks[:next].call(r)
              callbacks[:done].call()
            end
          end
        }
      })
    end
    proc { procs.each { |p| p.call() } }
  end

end
      

