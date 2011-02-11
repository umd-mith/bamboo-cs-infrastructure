class Utukku::Engine::Expression
  def build_async(context, av, callbacks)
    self.run(context, av).build_async(callbacks)
  end

  def build_async(context, av, callbacks)
    self.run(context, av).build_async(callbacks)
  end

  def async(context, av, callbacks)
    self.build_async(context, av, callbacks).call()
  end
end
