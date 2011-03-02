#require 'nokogiri'

class Utukku::Engine::Compiler
  def initialize
    @context = Utukku::Engine::Context.new
  end

  # Calls the right compiler object based on the root element
  def compile(xml)
    doc = nil

    if xml.is_a?(String)
      doc = Nokogiri::XML::Document.parse(xml)
      doc = doc.root
    elsif xml.is_a?(Nokogiri::XML::Document)
      doc = xml.root
    else
      doc = xml
    end

    @context.compile_structural(doc)
  end
end
