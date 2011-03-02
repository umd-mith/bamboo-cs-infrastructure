require 'utukku/engine/tag_lib'
require 'utukku/engine/ns'

module UtukkuX
  module CorporaCamp
    class Features < Utukku::Engine::TagLib

      NS = 'http://www.example.com/corpora-camp/ns/woodchipper/features'

      namespace NS

      mapping 'features' do |ctx, args|
        # Ruby goes here - return top 200 results 
      end
    end
  end
end
