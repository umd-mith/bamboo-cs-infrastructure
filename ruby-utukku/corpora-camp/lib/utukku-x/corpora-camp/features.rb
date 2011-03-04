require 'utukku/engine/tag_lib'
require 'utukku/engine/ns'
require 'utukku/engine/rest_client_iterator'

module UtukkuX
  module CorporaCamp
    class Features < Utukku::Engine::TagLib

      NS = 'http://www.example.com/corpora-camp/ns/woodchipper/features'

      namespace NS

      mapping 'features' do |ctx, args|
        request = { }

        Utukku::Engine::RestClientIterator.new({
          :body => request.to_json
        }) do |res|
          # Ruby goes here - return top 200 results 
        end
      end
    end
  end
end
