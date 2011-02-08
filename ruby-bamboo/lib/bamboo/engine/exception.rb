class Bamboo::Engine::Exception < StandardError
  attr_accessor :node

  def initialize(n = nil)
    @node = n
  end
end 

class Bamboo::Engine::ParserError < StandardError
end

class Bamboo::Engine::VariableAlreadyDefined < StandardError
  attr_accessor :variable

  def initialize(v)
    @variable = v
  end
end

class Bamboo::Engine::StateChangeException < Bamboo::Engine::Exception
end
