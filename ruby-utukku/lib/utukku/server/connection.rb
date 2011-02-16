class Utukku::Server::Connection
  def initialize(server, socket)
    @server = server
    @socket = socket
    @is_agent = false
    @namespaces = { }
    @running = false
  end

  def namespaces
    @namespaces
  end

  def register_namespaces(configs)
    @namespaces = configs
  end

  def exports_namespace?(ns)
    !@namespaces[ns].nil?
  end

  def is_agent?
    @is_agent
  end

  def socket
    @socket
  end

  def logger
    @server.logger
  end

  def remote_host(hostname = false)
    (@socket.tcp_socket.addr)[hostname ? 2 : 3]
  end

  def run
    # we need to let clients know what namespaces are available
    @running = true
    #self.send({
    #  'class' => 'flow.namespaces.registered',
    #  'data' => @server.namespaces
    #})
    self.send([ 'flow.namespaces.registered', nil, @server.namespaces ])

    #begin
      while data = @socket.receive
        msg = JSON.parse(data)
        msg = { 'class' => msg[0],
                'id' => msg[1],
                'data' => msg[2],
              }
        if @is_agent
          self.agent_handler(msg)
        else
          self.client_handler(msg)
        end
      end
    #rescue => e
    #  logger.error "Error reading or processing: #{e}"
    #end
    @running = false
  end

  def client_handler(msg)
    case msg['class']
      when 'flow.namespaces.register'
        @is_agent = true
        register_namespaces(msg['data'])
        @server.remove_client(self)
        @server.add_agent(self)
      when 'flow.create'
        msg['data']['expression'] =~ /^([^:]+):/
        prefix = $1
        ns = msg['data']['namespaces'][prefix]
        agents = @server.agents_exporting_namespace(ns)
        if agents.empty?
          send([ 'flow.produced', msg['id'], { } ])
        else
          @server.register_flow(self, msg['id'], agents)
          @server.narrow_broadcast(self, msg)
        end
      when 'flow.provide'
        @server.narrow_broadcast(self, msg)
      when 'flow.provided'
        @server.narrow_broadcast(self, msg)
      when 'flow.close'
        @server.narrow_broadcast(self, msg)
        @server.unregister_flow(self, msg['id'])
    end
  end

  def send(msg)
    begin
      @socket.send(msg.to_json) if @running
    rescue => e
      @running = false
      logger.error "Error sending data: #{e}"
    end
  end

  def agent_handler(msg)
    case msg['class']
      when 'flow.produce'
        @server.reply_to_client(msg)
      when 'flow.produced'
        @server.remove_agent_from_query(self, msg['id'])
    end
  end
end
