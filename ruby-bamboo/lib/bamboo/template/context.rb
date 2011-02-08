require 'radius'

module Bamboo::Template
  class Context < Radius::Context

  attr_reader :context

  def initialize(parser)
    super()
    @parser = parser
    globals.context = @context
    parser.tags.each do |name|
      define_tag(name) { |tag_binding| parser.render_tag(name, tag_binding) }
    end
  end

  def raise_errors?
    true
  end

  def render_tag(name, attributes = {}, &block)
    binding = @tag_binding_stack.last
    locals = binding ? binding.locals : globals
    set_process_variables(locals.page)
    super
  rescue Exception => e
    raise e if raise_errors?
    @tag_binding_stack.pop unless @tag_binding_stack.last == binding
    render_error_message(e.message)
  end

  def tag_missing(name, attributes = {}, &block)
    super
  rescue Radius::UndefinedTagError => e
    raise StandardTags::TagError.new(e.message)
  end

  private

    def render_error_message(message)
      "<div><strong>#{message}</strong></div>"
    end

    def set_process_variables(parser)
      #parser.request ||= @parser.request
      #parser.response ||= @parser.response
    end

  end
end

