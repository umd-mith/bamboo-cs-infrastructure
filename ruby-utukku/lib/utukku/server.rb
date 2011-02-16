require 'web_socket'
require 'json'
require 'yaml'
require 'uuid'
require 'log4r'

module Utukku
  class Server

    require 'utukku/server/connection'
    require 'utukku/server/config'
    include Log4r

    def initialize(&block)
      @clients = [ ]
      @agents = [ ]
      @flows = { }
      @uuid_to_flow = { }
      @uuid = UUID.new

      @port = 3000
      @accepted_domains = [ "*" ]
      @namespace_configs = { }

      @logger = Logger.new 'utukku'
      @logger.outputters = Outputter.stdout

      if block
        self.instance_eval &block
        self.setup
        self.run
      end
    end

    def port(p)
      @port = p
    end

    def accepted_domains(d)
      @accepted_domains = d
    end

    def namespace(ns, &block)
      @namespace_configs[ns] ||= Utukku::Server::Config::Namespace.new(ns, self)
      @namespace_configs[ns].instance_eval &block
    end

    def logging(&block)
      @logger.instance_eval &block
    end

    def logger
      @logger
    end

    def setup
      @server = WebSocketServer.new(
        :accepted_domains => @accepted_domains,
        :port => @port
      )
    end

    def run
      logger.info "Server is accepting connections on port #{@port}"

      @namespace_configs.each_pair do |ns, c|
        logger.info "#{ns} is accepting #{c.singular? ? 'one agent' : 'many agents'}"
      end

      @server.run { |ws|
        ws.handshake()
        client = Utukku::Server::Connection.new(self, ws)
        @clients.push(client)
        client.run
        remove_client(client)
        remove_agent(client)
      }
    end

    def remove_client(client)
      return unless @clients.include?(client)
      @clients = @clients - [ client ]
    end

    def add_agent(agent)
      @agents.push(agent)
      agent.namespaces.each_pair do |ns, config|
        @namespace_configs[ns] ||= Utukku::Server::Config::Namespace.new(ns, self)
        @namespace_configs[ns].add_agent(agent)
      end
    end

    def remove_agent(agent)
      return unless @agents.include?(agent)
      @agents = @agents - [ agent ]
      @flows.each_pair do |cid, fs|
        fs.each_pair do |fid, ff|
          ff[:agents] = ff[:agents] - [ agent ]

          if ff[:agents].empty?
            client = id_to_client(cid)
            client.send({
              'class' => 'flow.produced',
              'data' => { },
              'id' => fid,
            }) if !client.nil?
            @uuid_to_flow.delete(ff[:uuid])
            @flows[cid].delete(fid)
          end

        end
      end

      @namespace_configs.each_pair do |ns, nsc|
        nsc.remove_agent(agent)
      end
    end

    def agents_with_namespace(ns)
      @namespace_configs[ns] ? @namespace_configs[ns].agents : []
    end

    def agents_exporting_namespace(ns)
      agents_with_namespace(ns)
    end

    def id_to_client(id)
      @clients.select{ |c| c.object_id == id }.first
    end

    def register_flow(client, id, agents)
      uuid = @uuid.generate
      @flows[client.object_id] ||= { }
      @flows[client.object_id][id] = { :uuid => uuid, :agents => agents }
      @uuid_to_flow[uuid] = [ client.object_id, id ]
    end

    def unregister_flow(client, id)
      if @flows[client.object_id] && @flows[client.object_id][id]
        @uuid_to_flow.delete(@flows[client.object_id][id][:uuid])
        @flows[client.object_id].delete(id)
      end
    end

    def narrow_broadcast(client, msg)
      if @flows[client.object_id] && @flows[client.object_id][msg['id']]
        amsg = { 'class' => msg['class'],
                 'data'  => msg['data'],
                 'id'    => @flows[client.object_id][msg['id']][:uuid],
               }
        @flows[client.object_id][msg['id']][:agents].each do |agent|
          agent.send(amsg)
        end
      end 
    end
        
    def remove_agent_from_query(agent, id)
      f = @uuid_to_flow[id]
      return if f.nil?
      ff = @flows[f[0]][f[1]]

      ff[:agents] = ff[:agents] - [ agent ]

      if ff[:agents].empty?
        client = id_to_client(f[0])
        client.send({
          'class' => 'flow.produced',
          'data' => { },
          'id' => f[1]
        }) if !client.nil?
        @flows[f[0]].delete(f[1])
        @uuid_to_flow.delete(id)
      end
    end

    def reply_to_client(msg)
      f = @uuid_to_flow[msg['id']]
      return if f.nil?
      client = id_to_client(f[0])
      client.send({
        'class' => msg['class'],
        'data'  => msg['data'],
        'id'    => f[1]
      }) if !client.nil?
    end

    def namespaces
      namespaces = { }
      @agents.each do |agent|
        agent.namespaces.each_pair do |ns, config|
          namespaces[ns] = config
        end
      end

      namespaces
    end
  end
end
