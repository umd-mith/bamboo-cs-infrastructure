class Utukku::Server::Config::Namespace
  def initialize(ns)
    @namespace = ns
    @singular = false
    @agents = [ ]
  end

  def singular
    @singular = true
  end

  def singular?
    @singular
  end

  def multiple
    @singular = false
  end

  def add_agent(agent)
    @agents.push(agent)
  end

  def remove_agent(agent)
    @agents = @agents - [ agent ]
  end

  def agents
    @singular ? [ @agents.first ] : @agents
  end
end
