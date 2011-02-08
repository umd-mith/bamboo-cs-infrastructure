module Bamboo::Template
  module StandardTags
    include Bamboo::Template::Taggable

  desc %{
    Iterates through a set of data nodes.
      
    *Usage:*
      
    <pre><code><r:for-each select="./foo">...</r:for-each></code></pre>
  }
  tag 'for-each' do |tag|
    selection = tag.attr['select']
    c = tag.locals.context || tag.globals.context
    # ns = get_fabulator_ns(tag)
    items = c.nil? ? [] : c.eval_expression(selection)
    sort_by = tag.attr['sort']
    sort_dir = tag.attr['order'] || 'asc'
               
    if !sort_by.nil? && sort_by != ''
      parser = Bamboo::Engine::Parser.new
      sort_by_f = parser.parse(sort_by, c)
      items = items.sort_by { |i| c.with_root(i).eval_expression(sort_by_f).first.value }
      if sort_dir == 'desc'
        items.reverse!
      end
    end
    res = ''
    items.each do |i|
      next if i.empty?
      tag.locals.context = c.with_root(i)
      res = res + tag.expand
    end
    res.nil? ? '' : res
  end
            
  desc %{
    Selects the value and returns it in HTML.
    TODO: allow escaping of HTML special characters

    *Usage:*

    <pre><code><r:value select="./foo" /></code></pre>
  }
  tag 'value' do |tag|
    selection = tag.attr['select']
    c = tag.locals.context || tag.globals.context
    items = c.nil? ? [] : c.eval_expression(selection)
    res = items.collect{|i| i.to([Bamboo::Engine::NS::BAMBOO, 'html']).value }.join('')
    res.nil? ? '' : res
  end

  desc %{
    Chooses the first test which returns content.  Otherwise,
    uses the 'otherwise' tag.
  }
  tag 'choose' do |tag|
    @chosen ||= [ ]
    @chosen.unshift false
    ret = tag.expand
    @chosen.shift
    ret.nil? ? '' : ret
  end
    
  desc %{
    Renders the enclosed content if the test passes.
  }
  tag 'choose:when' do |tag|
    return '' if @chosen.first
    selection = tag.attr['test']
    c = tag.locals.context || tag.globals.context
    items = c.nil? ? [] : c.eval_expression(selection)
    if items.is_a?(Array)
      if items.empty? || items.select { |v| !!v.value }.size == 0
        return ''
      else
        @chosen[0] = true
        return tag.expand
      end   
    elsif items
      @chosen[0] = true
      return tag.expand
    end
    return ''
  end
    
  desc %{
    Renders the enclosed content.
  }
  tag 'choose:otherwise' do |tag|
    return '' if @chosen.first
    tag.expand
  end
end
end
