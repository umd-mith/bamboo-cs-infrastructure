class Utukku::Server::Config::Namespace
  def initialize(ns)
    @namespace = ns
    @singular = false
    @round_robin = false
    @agents = [ ]
    @agent_pos = 0
  end

  def singular
    @singular = true
  end

  def round_robin
    @round_robin = true
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
    return [ ] if @agents.empty?
    if @singular
      if @round_robin
        @agent_pos += 1
        @agent_pos %= @agents.size
      end
      return [ @agents[@agent_pos] ]
    else
      return @agents
    end
  end
end
