require 'utukku/engine/tag_lib'
require 'utukku/engine/ns'
require 'utukku/engine/rest_client_iterator'

module UtukkuX
  module CorporaCamp
    class Collections < Utukku::Engine::TagLib

      NS = 'http://www.example.com/corpora-camp/ns/collections'

      namespace NS

      def self.elastic_search_url=(u)
        @@elastic_search_url = u
      end

      function 'query' do |ctx, args|
        # build params for elastic search query
puts "query called!"
        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url,
          :params => { }
        }) do |res|
          results = JSON::decode(res.body)
puts YAML::dump(results)
          # return an iterator over the query results (up to 200 results)
        end
      end

      function 'query_count', {
        :namespaces => { :f => Utukku::Engine::NS::FAB },
        :code => 'f:count(my:query($1))' # max is 200 if we use above fctn
      }

      function 'facets' do |ctx, args|
        Utukku::Engine::RestClientIterator.new({
        }) do |res|
          results = JSON::decode(res.body)
puts YAML::dump(results)
          # return list of facets
        end
      end

#      consolidation 'facets', {
#        :namespaces => { :f => Utukku::Engine::NS::FAB },
#        :code => %Q{
#          (: Non-Ruby goes here :)
#          (: 'my' prefix is automatically defined to refer to this library :)
#        }
#      }

      mapping 'text2chunks' do |ctx, arg|
        Utukku::Engine::RestClientIterator.new({
        }) do |res|
          results = JSON::decode(res.body)
puts YAML::dump(results)
          # return list of chunks
          # { 'text-id' => arg.value,
          #   'chunk-id' => [ ... ]
          # }
        end
      end

      function 'chunk-meta' do |ctx, args|
        Utukku::Engine::RestClientIterator.new({
        }) do |res|
          results = JSON::decode(res.body)
puts YAML::dump(results)
          # return meta-data for chunk
        end
      end

    end
  end
end
