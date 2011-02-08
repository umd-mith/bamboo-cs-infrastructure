class Bamboo::Engine::Lib::Structurals::Attribute < Bamboo::Engine::Structural
  namespace Bamboo::Engine::NS::LIB

  attribute :name, :static => true
  attribute :ns, :static => true, :inherited => true
  attribute :static, :static => true, :type => :boolean
  attribute :eval, :static => true, :type => :boolean
  attribute :inherited, :static => true, :type => :boolean

  def is_static?
    @static
  end

  def value(context)
    v = context.attribute(@ns, @name, { :static => @static, :eval => @eval, :inherited => @inherited })
    if @eval || !@static
      v = context.root.anon_node(v, [ Bamboo::Engine::NS::FAB, 'expression' ])
    end
    v
  end
end
