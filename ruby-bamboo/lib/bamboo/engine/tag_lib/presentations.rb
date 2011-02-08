class Bamboo::Engine::TagLib::Presentations
  def initialize
    @transformations = Bamboo::Engine::TagLib::Transformations.new
    @interactives = { }
    @structurals = { }
  end

  def transformations_into
    @transformations
  end

  def interactives
    @interactives.keys
  end

  def structurals
    @structurals.keys
  end

  def interactive(nom)
    @interactives[nom.to_sym] = nil
  end

  def structural(nom)
    @structurals[nom.to_sym] = nil
  end

  def transform(fmt, doc, opts = { })
    @transformations.transform(fmt, doc, opts)
  end

  def get_root_namespaces(fmt)
    @transformations.get_root_namespaces(fmt)
  end
end
