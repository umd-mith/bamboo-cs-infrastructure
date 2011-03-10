class UtukkuX::CorporaCamp::WoodchipperURLBuilder < Utukku::Engine::TagLib

  namespace 'http://www.example.com/corpora-camp/ns/woodchipper/url-builder'

  function 'build-text-url' do |ctx, args|
    a = args[0]
puts YAML::dump(args)
    begin
      args[0] = args[0].flatten.first
      if args[0].value.nil?
        args[0] = args[0].children
      end
    rescue
      args[0] = a
    end
    collection = args[0].flatten.first.value

    a = args[1]
    begin
      args[1] = args[1].flatten.first
      if args[1].value.nil?
        args[1] = args[1].children
      end
    rescue
      args[1] = a
    end
    ids = args[1].flatten.first.value

    case collection
      when 'hathi'
        return "http://hdl.handle.net/2027/#{ids['textid']}"
      when 'perseus'
      when 'eebo'
        if ids.include?('marc')
          return "http://gateway.proquest.com/openurl?ctx_ver=Z39.88-2003&res_id=xri:eebo&rft_id=xri:eebo:citation:#{ids['marc']}"
        end
      when 'ecco'
      when 'evans'
    end
  end

  function 'build-chunk-url' do |ctx, args|
    a = args[0]
    begin
      args[0] = args[0].to_a.flatten.first
      if args[0].value.nil?
        args[0] = args[0].children
      end
    rescue
      args[0] = a
    end
    collection = args[0].to_a.flatten.first.value

    a = args[1]
    begin
      args[1] = args[1].to_a.flatten.first
      if args[1].value.nil?
        args[1] = args[1].children
      end
    rescue
      args[1] = a
    end
    ids = args[1].to_a.flatten.first.value

    case collection
      when 'hathi'
        return "http://babel.hathitrust.org/cgi/pt?seq=146&view=image&size=100&id=#{ids["textid"]}&u=1&num=#{ids["chunkid"]}"
      when 'perseus'
      when 'eebo'
        if ids.include?('vid')
          return "http://gateway.proquest.com/openurl?ctx_ver=Z39.88-2003&res_id=xri:eebo&rft_id=xri:eebo:image:#{ids["vid"]}:#{ids["chunkid"]}"
        end
      when 'ecco'
      when 'evans'
    end
  end
end
