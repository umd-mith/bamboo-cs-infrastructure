require 'utukku'
require 'utukku/engine'
require 'utukku/client'
require 'optparse'
require 'terminal-table'

module Utukku
  class Shell
    require 'utukku/shell/io-method'

    @@READLINE_AVAILABLE = true
    begin
      require 'readline'
    rescue
      @@READLINE_AVAILABLE = false
    end

    def initialize(&block)
      @no_pager = false
      @use_readline = true
      @config_file = ENV['HOME'] + '/.utukkurc'
      @debug = false
      @help = false
      @prompt = 'utukku>'
      @suppress_narrative = false
      @parser = Utukku::Engine::Parser.new
      @context = Utukku::Engine::Context.new
      @buffer = ''
      @line_no = 1
      @io = Utukku::Shell::StdioIOMethod.new

      @silent = true
      instance_eval &block
      @silent = false

      OptionParser.new do |opt|
        opt.banner = "Usage: utukku [options]"
        opt.separator ""
        opt.separator "Options are ..."

        opt.on_tail("-h", '--help', '-H', "Display this help message.") do
          puts opt
          exit
        end

        opt.on('-d', '--debug', 'Turns on debug mode.') { |v|
          @debug = v
        }

        opt.on('-p', '--nopager', 'Suppresses the pager.') { |v|
          @no_pager = v
        }

        opt.on('-r', '--noreadline', 'Suppresses ReadLine support.') { |v|
          @use_readline = !v
        }

        opt.on('-f', '--config FILE', 'Use given rc file instead of ~/.utukkurc.' ) { |f|
          @config_file = f
        }
      end.parse!

      if @help
        puts self.usage
        return
      end

      if @use_readline
        begin
          require 'readline'
        rescue
          @use_readline = false
        end
      end

      if @use_readline
        @io  = Utukku::Shell::ReadlineIOMethod.new
        @io.prompt = @prompt
      end


      self.print "utukku shell -- Utukku (v#{Utukku::VERSION})\n"
      self.print "ReadLine support enabled\n" if @use_readline

      begin
        self.load_file(@config_file)
      rescue Errno::ENOENT
        # ignore errors loading config file
      end

      self.run_until_eof
    end

    def config_file(f)
      @config_file = f
    end

    def prompt(p)
      @prompt = p
    end

    def debug(d)
      @debug = d
    end

    def load_file(f)
      old_io = @io
      old_silent = @silent
      @silent = true
      begin
        @io = Utukku::Shell::FileIOMethod.new(f)
        self.print "Loading #{f}...\n"
        self.run_until_eof
      ensure
        @io = old_io
        @silent = old_silent
      end
    end

    def run_until_eof
      while !@io.eof?
        self.interpret(@io.gets)
      end
    end

    def print(*stuff)
      return if @silent
      @io.print stuff
    end

    def interpret(input)
      return if input =~ /^\s*$/
      input = '\quit' if input.nil?
      if input =~ /^\\(.*)$/
        self.immediate($1)
      else
        input = @buffer + ' ' + input
        it = nil
        #begin
          it = @parser.parse(input, @context)
        #rescue => e
        #  if input.gsub!(/^.*?;/, '')
        #    print "  #{e}"
        #  end
        #  input.gsub!(/^\s*/,'')
        #  input.gsub!(/\s*$/,'')
        #  @buffer = input
        #  if @buffer == ''
        #    @io.prompt = @prompt
        #  else
        #    @io.prompt = @prompt + "..."
        #  end
        #  return
        #end
        @buffer = ''
        @io.prompt = @prompt
        if !it.nil?
          is_first = true
          done = false
          it.async(@context, false, {
            :next => @silent ? proc { |v| } : proc { |v|
              if is_first
                self.print(v)
                is_first = false
              else
                self.print(", #{v}")
              end
            },
            :done => @silent ? proc { done = true } : proc {
              done = true
              self.print("\nOK\n")
            }
          })
          until done
            @client.wake
            sleep 0.01
          end
        else
          unless @suppress_narrative
            self.print("Error interpreting [#{input}]\n")
          end
          return
        end
        @line_no += 1
      end
    end

    def immediate(cmd)
      bits = cmd.split(/\s+/)
      case bits[0]
        when '?'
          self.print(%Q{
Commands:
  \\?                      Print this list.
  \\connect [host] [port]  Connect to the CorporaCamp server at the host/port
  \\connection             Show connection information to CorporaCamp server
  \\reconnect              Reconnect to the CorporaCamp server
  \\namespaces             List defined namespaces and namespace handlers
  \\quit                   Exit the console.
})
        when 'quit'
          if @client
            @client.interactive = false
            @client.manage_flow_lock
            @client.close
          end
          exit(0)
        when 'connect'
          self.connect(bits[1], bits[2], bits[3])
        when 'connection'
          self.connection
        when 'reconnect'
          self.reconnect
        when 'namespaces'
          self.namespaces
      end
    end

    def connect(host, port, path)
      url = "ws://#{host}:#{port}/#{path}"
      if !@client.nil? && @client.url != url
        @client.manage_flow_lock
        @client.close
      end
      begin
        @client = Utukku::Client.new(url)
        @client.interactive = true
        @client.setup
      rescue => e
        self.print("Unable to connect to client: #{e}\n")
      end
    end

    def connection
      if !@client
        self.print("You are not connected to a CorporaCamp server\n")
        return
      end
      begin
        url = @client.url
        url =~ /^ws:\/\/(.*?):(\d+)\/(.*)$/
        self.print("You are connected to #{$1} #{$2} #{$3}\n")
      rescue => e
        self.print("Unable to determine your connection: #{e}\n")
      end
    end

    def reconnect
      return unless @client
      begin
        url = @client.url
        @client.interactive = false
        @client.manage_flow_lock
        @client.close
        @client = Utukku::Client.new(url)
        @client.interactive = true
        @client.setup
        url =~ /^ws:\/\/(.*?):(\d+)\/(.*)$/
        self.print("Reconnected to #{$1} #{$2} #{$3}\n")
      rescue => e
        self.print("Unable to connect to client: #{e}")
      end
    end

    def namespaces
      spaces = { }
      @context.each_namespace do |p, ns|
        spaces[ns] = [ p, '-' ]
      end
      Utukku::Engine::TagLib::Registry.instance.handlers.each_pair do |ns, h|
        if spaces[ns].nil?
          spaces[ns] = [ '', '-' ]
        end
        spaces[ns][1] =
          h.kind_of?(Utukku::Engine::TagLib::Remote) ? 'Remote' : 'Local' 
      end
      
      table = Terminal::Table.new do |t|
        t.headings = 'Prefix', 'Namespace', 'Handler'
        spaces.keys.sort.each do |ns|
          info = spaces[ns]
          t << [ info[0], ns, info[1]||"-" ]
        end
      end
      begin
        self.print(table)
      rescue
      end
    end
  end
end
