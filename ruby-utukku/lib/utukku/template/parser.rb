module Utukku::Template
  class Parser
    include Utukku::Template::Taggable
    include Utukku::Template::StandardTags

    def parse(context, text)
      if !@context
        @context = Context.new(self)
      end
      if !@parser
        @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
      end
      @context.globals.context = context

      # N.B.: these substitutions work around a bug in Radius that shows
      #       up when working with XML+namespaces

      text.gsub!(/&/, '&amp;')
      text.gsub!(/<\//, '&lt;/')
      text.gsub!(/&lt;\/r:/, '</r:')

      r = @parser.parse(text)

      r.gsub!(/&lt;\//, '</')
      r.gsub!(/&amp;/, '&')

      begin
        Utukku::Template::ParseResult.new(r)
      rescue => e
        "<!-- unable to parse XML: #{e} -->" + r
      end
    end
  end
end
