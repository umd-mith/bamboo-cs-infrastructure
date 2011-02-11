require 'utukku/engine/tag_lib'

module Example
  class TagLib < Utukku::Engine::TagLib

  namespace 'http://www.example.com/echo/1.0#'

  mapping 'double' do |ctx, arg|
    arg.value * 2
  end

  end
end
