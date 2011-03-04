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

         a0 = args[0]
         begin
           args[0] = args[0].flatten.first
           if args[0].value.nil?
             args[0] = args[0].children
           end
         rescue
           args[0] = a0
         end
        query = args[0].flatten.first.value
        if query.is_a?(Hash)
          request["query"] = {
            "term" => { }
          }
          query.each_pair do |k,v|
            request["query"]["term"][k] = v.downcase
          end
        else
          request["query"] = {
            "term" => { 
              "plain" => query.downcase
            }
          }
        end

        begin_date = 0
        end_date = 0
        if args.size > 1
          begin_date = (args[1].flatten.first.to_s.to_i rescue 0)
        end
        if args.size > 2
          end_date = (args[2].flatten.first.to_s.to_i rescue 0)
        end

        begin_date = 0 if begin_date < 1100 || begin_date > 2200
        end_date   = 0 if end_date   < 1100 || end_date   > 2200

        if begin_date == end_date
          if begin_date != 0 
            # single year constraint
          end
        else
          # year range constraint
        end

        request["size"] = 200
        request["script_fields"] = {
          "title" => { "script" => "_source.metadata.title" },
          "textid" => { "script" => "_source.metadata.textid" },
          "author" => { "script" => "_source.metadata.author" },
          "date" => { "script" => "_source.metadata.date" },
        }

        Utukku::Engine::RestClientIterator.new({
          :method => :get,
          :url => @@elastic_search_url + "_search",
          :body => request.to_json
        }) do |res|
          results = JSON.parse(res.body)
          # return an iterator over the query results (up to 200 results)
          if results["hits"]["total"] == 0
            Utukku::Engine::NullIterator.new
          else
            Utukku::Engine::ConstantIterator.new(results["hits"]["hits"].collect { |hit|
              h = hit['fields'] || {}
# removed _id and _type
              ['_index', '_score'].each do |k|
                h[k] = hit[k]
              end
              h
            })
          end
        end
      end

      function 'query_count', {
        :namespaces => { :f => Utukku::Engine::NS::FAB },
        :code => 'f:count(my:query($1, $2, $3))' # max is 200 if we use above fctn
      }

      function 'facets' do |ctx, args|
        return Utukku::Engine::ConstantIterator.new([
          { 'label' => 'title',
            'type' => 'text',
          },
          { 'label' => 'author',
            'type' => 'text',
          },
#          { 'label' => 'year',
#            'type' => 'date',
#            'value' => [ "1550", "1560" ],
#            'count' => [ 20, 23 ],
#            'min' => 1100,
#            'max' => 2200
#          }
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
        textid = arg.to_s

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
        textid  = args[0].flatten.first.to_s
        chunkid = args[1].flatten.first.to_s

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
