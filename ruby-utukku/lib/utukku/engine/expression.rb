class Utukku::Engine::Expression
  def build_async(context, av, callbacks)
    self.run(context, av).build_async(callbacks)
  end

  def build_async(context, av, callbacks)
    proc {
      self.run(context, av).to_a.each do |v|
        callbacks[:next].call(v)
      end
      callbacks[:done].call()
    }
  end

  def async(context, av, callbacks)
    self.build_async(context, av, callbacks).call()
  end
end
