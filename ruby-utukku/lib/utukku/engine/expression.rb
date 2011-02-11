class Utukku::Engine::Expression
  def async(context, av, callbacks)
puts "async run of #{self}"
    self.run(context, av).async(callbacks)
  end
end
