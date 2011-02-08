Given /the statemachine/ do |doc_xml|
  @context ||= Bamboo::Engine::Context.new
  @compiler ||= Bamboo::Engine::Compiler.new

  if @sm.nil?
    @sm = @compiler.compile(doc_xml)
    #@sm.compile_xml(doc_xml)
  else
    @sm.compile_xml(doc_xml)
  end
  @sm.init_context(@context)
  puts YAML::dump(@context)
end

Given /the library/ do |doc_xml|
  @context ||= Bamboo::Engine::Context.new
  @compiler ||= Bamboo::Engine::Compiler.new

  if @library.nil?
    @library = @compiler.compile(doc_xml)
  else
    @library.compile_xml(doc_xml, @context)
  end

puts YAML::dump(@library)
  @library.register_library
end

When /I run it with the following params:/ do |param_table|
  params = { }
  param_table.hashes.each do |hash|
    params[hash['key']] = hash['value']
  end
  @sm.run(params)
  #puts YAML::dump(@sm)
end

Then /it should be in the '(.*)' state/ do |s|
  @sm.state.should == s
end
