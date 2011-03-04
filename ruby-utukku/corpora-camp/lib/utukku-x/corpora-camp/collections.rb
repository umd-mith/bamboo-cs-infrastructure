require 'utukku/engine/tag_lib'
require 'utukku/engine/ns'
require 'utukku/engine/rest_client_iterator'
require 'utukku/engine/map_iterator'

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
        request = {}
       # request.update( { :query  => @query } )
       # request.update( { :sort   => @sort } )   if @sort
       # request.update( { :facets => @facets } ) if @facets
       # request.update( { :size => @size } )     if @size
       # request.update( { :from => @from } )     if @from
       # request.update( { :fields => @fields } ) if @fields

        request["query"] = {
          "term" => { "plain" => args[0].to_s }
        }
        request["size"] = 200
        request["script_fields"] = {
          "title" => { "script" => "_source.metadata.title" },
          "textid" => { "script" => "_source.metadata.textid" },
          "author" => { "script" => "_source.metadata.author" },
        }

        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url + "_search",
          :body => request.to_json
        }) do |res|
          results = JSON.parse(res.body)
          # return an iterator over the query results (up to 200 results)
          Utukku::Engine::ConstantIterator.new(results["hits"]["hits"].collect { |hit|
            h = hit['fields'] || {}
            ['_id', '_index', '_score', '_type'].each do |k|
              h[k] = hit[k]
            end
            h
          })
        end
      end

      function 'query_count', {
        :namespaces => { :f => Utukku::Engine::NS::FAB },
        :code => 'f:count(my:query($1))' # max is 200 if we use above fctn
      }

      function 'facets' do |ctx, args|
        return Utukku::Engine::ConstantIterator.new([
          { 'label' => '_lucene',
            'type' => 'query',
          },
          { 'label' => 'year',
            'type' => 'date',
            'value' => [ "1550", "1560" ],
            'count' => [ 20, 23 ],
            'min' => 1100,
            'max' => 2200
          }
        ])
        request = { }
        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url + "_search",
          :body => request.to_json
        }) do |res|
          results = JSON.parse(res.body)
puts YAML::dump(results)
          # return list of facets
        end
      end

      mapping 'text2chunks' do |ctx, arg|
        request = { }
        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url + "_search",
          :body => request.to_json
        }) do |res|
          results = JSON.parse(res.body)
puts YAML::dump(results)
          # return list of chunks
          # { 'text-id' => arg.value,
          #   'chunk-id' => [ ... ]
          # }
        end
      end

      function 'chunk-meta' do |ctx, args|
        request = { }
        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url + "_search",
          :body => request.to_json
        }) do |res|
          results = JSON.parse(res.body)
puts YAML::dump(results)
          # return meta-data for chunk
        end
      end

    end
  end
end
