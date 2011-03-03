require "java"
# TODO: fix path to jar file
require "target/woodchipper-0.0.1-jar-with-dependencies.jar"

class UtukkuX::CorporaCamp::WoodchipperURLBuilder < Utukku::Engine::TagLib

  @@builder = org.projectbamboo.corporacamp.metadata.WoodchipperURLBuilder.new()

  NS = 'http://www.example.com/corpora-camp/ns/woodchipper/url-builder'
  namespace NS

  function 'build-text-url', do |ctx, args|
    collection = args[0].to_s
    ids = args[1].to_a
    Utukku::Engine::MapIterator(ids) do |id|
      @@builder.buildTextURL(collection, id)
    end
  end

  function 'build-chunk-url', do |ctx, args|
    collection = args[0].to_s
    ids = args[1].to_a
    Utukku::Engine::MapIterator(ids) do |id|
      @@builder.buildChunkURL(collection, id)
    end
  end
end
