class Utukku::Engine::Lib::Structurals::Structural < Utukku::Engine::Structural
  namespace Utukku::Engine::NS::LIB

  attribute :name, :static => true

  contains :attribute

  has_actions
end
