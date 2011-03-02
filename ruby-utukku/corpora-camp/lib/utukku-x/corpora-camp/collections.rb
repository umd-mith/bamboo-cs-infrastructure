require 'utukku/engine/tag_lib'
require 'utukku/engine/ns'

# TODO: replace placeholder .jar
require 'utukku-x/corpora-camp/collections/lucene.jar'

module UtukkuX
  module CorporaCamp
    class Collections < Utukku::Engine::TagLib

      NS = 'http://www.example.com/corpora-camp/ns/collections'

      namespace NS

      function 'query' do |ctx, args|
        # Ruby goes here - return top 200 results
        lucene.query(args.first.value)
      end

      function 'query_count', {
        :namespaces => { :f => Utukku::Engine::NS::FAB },
        :code => 'f:count(my:query($1))'
      }

      reduction 'facets' do |ctx, args|
        
      end

      consolidation 'facets', {
        :namespaces => { :f => Utukku::Engine::NS::FAB },
        :code => %Q{
          (: Non-Ruby goes here :)
          (: 'my' prefix is automatically defined to refer to this library :)
        }
      }

      mapping 'text2chunks' do |ctx, arg|
      end

      function 'chunk-meta' do |ctx, args|
      end

    end
  end
end
