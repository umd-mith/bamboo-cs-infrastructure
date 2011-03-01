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
    self.send([ 'flow.namespaces.registered', nil, @server.namespaces ])

    #begin
      while data = @socket.receive
        msg = [ ]
        bits = data.split(/,/,3)

        msg.push(bits[0].gsub(/^\[\s*["']/, '').gsub(/["']\s*$/, ''))
        msg.push(bits[1] == 'null' ? nil : bits[1].gsub(/^\s*["']/, '').gsub(/['"]\s*$/, ''))
        msg.push(bits[2].gsub(/\s*\]$/, ''))

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
    case msg[0]
      when 'flow.namespaces.register'
        @is_agent = true
        register_namespaces(JSON.parse(msg[2]))
        @server.remove_client(self)
        @server.add_agent(self)
      when 'flow.create'
        msg[2] = JSON.parse(msg[2])
        msg[2]['expression'] =~ /^([^:]+):/
        prefix = $1
        ns = msg[2]['namespaces'][prefix]
        agents = @server.agents_exporting_namespace(ns)
        if agents.empty?
          send([ 'flow.produced', msg[1], { } ])
        else
          @server.register_flow(self, msg[1], agents)
          @server.narrow_broadcast(self, msg)
        end
      when 'flow.provide'
        @server.narrow_broadcast(self, msg)
      when 'flow.provided'
        @server.narrow_broadcast(self, msg)
      when 'flow.close'
        @server.narrow_broadcast(self, msg)
        @server.unregister_flow(self, msg[1])
    end
  end

  def send(msg)
    begin
      if(msg[2].kind_of?(String))
        if(msg[1].nil?)
          @socket.send("[\"#{msg[0]}\",null,#{msg[2]}]")
        else
          @socket.send("[\"#{msg[0]}\",\"#{msg[1]}\",#{msg[2]}]")
        end
      else
        @socket.send(msg.to_json) if @running
      end
    rescue => e
      @running = false
      logger.error "Error sending data: #{e}"
    end
  end

  def agent_handler(msg)
    case msg[0]
      when 'flow.produce'
        @server.reply_to_client(msg)
      when 'flow.produced'
        @server.remove_agent_from_query(self, msg[1])
    end
  end
end
