require 'nokogiri'

module Bamboo::Template
  class ParseResult

    def initialize(text)
      ## we want to build up the XPath expression for structural and
      ## interactive elements for use in adding default info and
      ## building names for those elements -- saves the XSLT from having
      ## to do this

      structurals = { }
      interactives = { }

      Bamboo::Engine::TagLib.namespaces.each_pair do |ns, ob|
        x = ob.presentation.structurals || []
        structurals[ns] = x unless x.nil? || x.empty?
        x = ob.presentation.interactives || []
        interactives[ns] = x unless x.nil? || x.empty?
      end

      @namespaces = { }
      i = 1
      (structurals.keys + interactives.keys).uniq.sort.each do |ns|
        @namespaces["fab_ns_#{i.to_s}"] = ns
        i += 1
      end

      structural_xpaths = []
      interactive_xpaths = []
      interesting_xpaths = [ ]
      @fab_prefix = ''

      @namespaces.keys.each do |p|
        @fab_prefix = p if @namespaces[p] == Bamboo::Engine::NS::FAB
        structural_xpaths += structurals[@namespaces[p]].collect{ |e| "ancestor::#{p}:#{e}" }
        interactive_xpaths += interactives[@namespaces[p]].collect{ |e| "//#{p}:#{e}" }
        interesting_xpaths += structurals[@namespaces[p]].collect{ |e| "//#{p}:#{e}" }
      end

      @structural_xpath = structural_xpaths.join("[@id != ''] | ") + "[@id != '']"
      @interactive_xpath = interactive_xpaths.join(" | ")

      @interesting_xpath = (interactive_xpaths + interesting_xpaths).join(" | ")

      ## We also may do our dependency tree -- namespaces in the
      ## root element of the stylesheet will be run after the current
      ## stylesheet

      @doc = Nokogiri::XML::Document.parse(text)

      @fab_ns = nil
      @doc.root.namespace_definitions.each do |ns|
        if ns.href == Bamboo::Engine::NS::FAB
          @fab_ns = ns
        end
      end

      if @fab_ns.nil?
        @fab_ns = Nokogiri::XML::Namespace.new(@doc.root, @fab_prefix, Bamboo::Engine::NS::FAB)
      end
    end

    # This function walks through all of the elements in the provided
    # markup and adds f:default child elements.  TagLibs declare data
    # elements that should receive default values.
    def add_default_values(context)
      return if context.nil?
      each_form_element do |el|
        own_id = el.attributes['id']
        next if own_id.nil? || own_id.to_s == ''

        default = nil
        default = el.xpath("./#{@fab_prefix}:default", @namespaces).to_a

        id = el_id(el)
        ids = id.split('/')
        l = context.traverse_path(ids)
        if !l.nil? && !l.empty?
          if !default.nil? && !default.empty?
            default.each { |d| d.remove! }
          end
          l.collect{|ll| ll.value}.each do |v|
            el << text_node('default', v)
          end
        end
      end
    end

    def add_missing_values(missing = [ ])
      each_form_element do |el|
        id = el_id(el)
        next if id == ''
        next unless missing.include?(id)
        el.attributes["missing"] = "1"
      end
    end

    def add_errors(errors = { })
      each_form_element do |el|
        id = el_id(el)
        next if id == ''
        next unless errors.has_key?(id)
        if errors[id].is_a?(Array)
          errors[id].each do |e|
            el << text_node('error', e) 
          end
        else
          el << text_node('error', errors[id])
        end
      end
    end

    def add_captions(captions = { })
      each_element do |el|
        id = el_id(el)
        next if id == ''
        caption = nil
        if captions.is_a?(Hash)
          caption = captions[id]
        else
          caption = captions.traverse_path(id.split('.')).first.to_s
        end

        next if caption.nil?

        is_grid = false
        if el.name == 'grid'
        else
          cap = el.xpath("./#{@fab_prefix}:caption", @namespaces).first
          if cap.nil?
            el << text_node('caption', caption)
          else
            cap.content = caption
            cap.parent << text_node('caption', caption)
            cap.remove
          end
        end
      end
    end

    def to_s
      @doc.to_s.gsub(/^\s*<\?xml\s+.*?\?>\s*/, '')
    end

    def to_html(popts = { })
      opts = { :form => true, :theme => 'coal' }.update(popts)

      deps = { }
      Bamboo::Engine::TagLib.namespaces.each_pair do |ns, ob|
        deps[ns] = ob.presentation.get_root_namespaces(:html) & (Bamboo::Engine::TagLib.namespaces.keys) - [ ns ]
      end

      ordered_ns = [ ]

      next_round = ([ Bamboo::Engine::NS::FAB ] + deps.keys.select { |k| deps[k].empty? }).uniq

      while !next_round.empty? do
        next_round.each { |k| deps.delete(k) }

        ordered_ns += next_round

        deps.keys.each do |k|
          deps[k] -= ordered_ns
        end

        next_round = deps.keys.select{ |k| deps[k].empty? }
      end

      ordered_ns.reverse!

      res = @doc
      ordered_ns.each do |ns|
        ob = Bamboo::Engine::TagLib.namespaces[ns]
        next if ob.nil?
        res = ob.presentation.transform(:html, res, opts)
      end

      ret = ''
      if opts[:form]
        ret = res.to_s.gsub(/^\s*<\?xml\s+.*?\?>\s*/, '').gsub(/xmlns(:\S+)?=['"][^'"]*['"]/, '').gsub(/\s+/, ' ').gsub(/\s+>/, '>')
      else
        ret = res.xpath('//form/*').collect{ |e| e.to_s}.join('').gsub(/^\s*<\?xml\s+.*?\?>\s*/, '').gsub(/xmlns(:\S+)?=['"][^'"]*['"]/, '').gsub(/\s+/, ' ').gsub(/\s+>/, '>')

      end

      ret.gsub!(/<(div\s*[^<]*?)\/>/, "<\\1></div>")
      ret.gsub!(/<(span\s*[^<]*?)\/>/, "<\\1></span>")
      ret
    end

protected

    def each_element(&block)
      @doc.root.xpath(@interesting_xpath, @namespaces).each do |el|
        yield el
      end
    end

    def each_form_element(&block)
      @doc.root.xpath(@interactive_xpath, @namespaces).each do |el|
        yield el
      end
#      @doc.root.find(%{
#        //text
#        | //textline
#        | //textbox
#        | //editbox
#        | //asset
#        | //password
#        | //selection
#        | //grid
#        | //submit
#      }).each do |el|
#        yield el
#      end
    end

    def el_id(el)
      own_id = el.attributes['id']
      return '' if own_id.nil? || own_id == ''

#      ancestors = el.find(%{
#        ancestor::option[@id != '']
#        | ancestor::group[@id != '']
#        | ancestor::form[@id != '']
#        | ancestor::container[@id != '']
#      })
      ancestors = el.xpath(@structural_xpath, @namespaces)
      ids = ancestors.collect{|a| a.attributes['id']}.select{|a| !a.nil? }
      ids << own_id
      ids.collect{|i| i.to_s}.join('/')
    end

    def text_node(n,t)
      @doc.create_element(n, t) { |node|
        node.namespace = @fab_ns
      }
    end
  end
end
