class Bamboo::Engine::Parser::Step
  def initialize(a,n)
    @axis = a
    @node_test = n
  end

  def run(context, autovivify = false)
    c = context.root
    if !@axis.nil? && @axis != '' && context.root.roots.has_key?(@axis) &&
        @axis != context.root.axis
      c = context.root.roots[@axis]
    end
    if @node_test.is_a?(String)
      n = @node_test
    else
      n = (@node_test.run(context).last.value rescue nil)
    end 
    return [ ] if n.nil?
    if n == '*'
      possible = c.children
    else
      possible = c.children.select{ |cc| cc.name == n }
      if possible.empty? && autovivify
        #Rails.logger.info("Autovivifying #{n}")
        possible = context.with_root(c).traverse_path([ n ], true)
      end
    end
    return possible
  end

  def create_node(context)
    return nil if node_text == '*'

    c = Bamboo::Engine::Memory::Node.new(context.root.axis, context.root.roots, nil, [])
    c.name = @node_test
    context.root.add_child(c)
    c
  end
end
