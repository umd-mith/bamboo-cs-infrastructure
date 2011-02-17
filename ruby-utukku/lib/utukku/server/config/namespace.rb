class Utukku::Server::Config::Namespace
  def initialize(ns, server)
    @namespace = ns
    @server = server
    @singular = false
    @round_robin = false
    @agents = [ ]
    @agent_pos = 0
    @allow_all = true
    @deny_all = false
    @allow_from = [ ]
    @deny_from = [ ]
  end

  def logger
    @server.logger
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

  def allow_from_all
    @allow_all = true
    @deny_all = false
    @allow_from = [ ]
    @deny_from = [ ]
  end

  def deny_from_all
    @allow_all = false
    @deny_all = true
    @allow_from = [ ]
    @deny_from = [ ]
  end

  def allow_from(ips)
    @allow_from = ips
  end

  def deny_from(ips)
    @deny_from = ips
  end

  def add_agent(agent)
    return if @deny_all && @allow_from.empty?
    return if @deny_from.include?(agent.remote_host) || @deny_from.include?(agent.remote_host(true))
    if @allow_all || @allow_from.include?(agent.remote_host) || @allow_from.include?(agent.remote_host(true))
      logger.info "Adding #{agent.remote_host} / #{agent.remote_host(true)} for #{@namespace}"
      @agents.push(agent)
    end
  end

  def remove_agent(agent)
    if @agents.include?(agent)
      logger.info "Removing an agent from #{agent.remote_host} / #{agent.remote_host(true)} for #{@namespace}"
      @agents = @agents - [ agent ]
      if @agents.empty?
        logger.info "All agents removed from #{@namespace}"
      end
    end
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
