require 'web_socket'
require 'json'
require 'yaml'
require 'uuid'

module Utukku
  class Server

    require 'utukku/server/connection'

    attr_accessor :port

    def initialize(&block)
      @clients = [ ]
      @agents = [ ]
      @flows = { }
      @uuid_to_flow = { }
      @uuid = UUID.new

      if block
        yield self
        self.setup
        self.run
      end
    end

    def setup
      @server = WebSocketServer.new(
        :accepted_domains => 'localhost',
        :port => @port
      )
    end

    def run
      @server.run { |ws|
        ws.handshake()
        client = Utukku::Server::Connection.new(self, ws)
        @clients.push(client)
        client.run
        @clients = @clients - [ client ]
        @agents = @agents - [ client ]
      }
    end

    def remove_client(client)
      @clients = @clients - [ client ]
    end

    def add_agent(agent)
      @agents.push(agent)
    end

    def agents_with_namespace(ns)
      @agents.select{ |a| a.exports_namespace?(ns) }
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

    def agents_exporting_namespace(ns)
      @agents.select{ |a| a.exports_namespace?(ns) }
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
