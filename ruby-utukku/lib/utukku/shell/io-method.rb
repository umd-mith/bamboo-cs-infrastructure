class Utukku::Shell
  STDIN_FILE_NAME = "(line)"

  class IOMethod
    attr_reader :file_name
    attr_accessor :prompt

    def initialize(file = STDIN_FILE_NAME)
      @file_name = file
    end

    def gets
      raise NotImplementedError, "gets"
    end

    def print(*stuff)
      raise NotImplementedError, "print"
    end

    def readable_after_eof?
      false
    end
  end

  class StdioIOMethod < IOMethod
    def initialize
      super
      @line_no = 0
      @line = [ ]
    end

    def gets
      print @prompt
      @line[@line_no += 1] = $stdin.gets
    end

    def print(*stuff)
      Kernel.print(stuff)
    end

    def eof?
      $stdin.eof?
    end

    def readable_after_eof?
      true
    end

    def line(line_no)
      @line[line_no]
    end
  end

  class FileIOMethod < IOMethod
    def initialize(file)
      super
      @io = open(file)
    end

    def eof?
      @io.eof?
    end

    def gets
      @io.gets
    end

    def print(*stuff)
      # we don't do anything
    end
  end

  begin
    require 'readline'
    class ReadlineIOMethod < IOMethod
      include Readline
      def initialize
        super

        @line_no = 0
        @line = [ ]
        @eof = false
      end

      def gets
        if l = readline(@prompt, false)
          HISTORY.push(l) if !l.empty?
          @line[@line_no += 1] = l + "\n"
        else
          @eof = true
          l
        end
      end

      def print(*stuff)
        Kernel.print(stuff)
      end

      def eof?
        @eof
      end

      def readable_after_eof?
        true
      end
  
      def line(line_no)
        @line[line_no]
      end
    end
  rescue LoadError
  end
end
