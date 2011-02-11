class Utukku::Engine::Exception < StandardError
  attr_accessor :node

  def initialize(n = nil)
    @node = n
  end
end 

class Utukku::Engine::ParserError < StandardError
end

class Utukku::Engine::VariableAlreadyDefined < StandardError
  attr_accessor :variable

  def initialize(v)
    @variable = v
  end
end

class Utukku::Engine::StateChangeException < Utukku::Engine::Exception
end
