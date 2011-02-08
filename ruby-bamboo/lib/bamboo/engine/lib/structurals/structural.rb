class Bamboo::Engine::Lib::Structurals::Structural < Bamboo::Engine::Structural
  namespace Bamboo::Engine::NS::LIB

  attribute :name, :static => true

  contains :attribute

  has_actions
end
