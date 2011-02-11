package Utukku::Shell;
  use Moose;

  use Moose::Exporter;
  use Utukku;
  use Utukku::Engine::Parser;
  use Utukku::Engine::Context;
  use Utukku::Engine::Types qw( Iterator );
  use IO::Handle;

  with 'MooseX::Getopt';

  Moose::Exporter -> setup_import_methods(
    as_is => [ qw( shell ) ]
  );

  has 'd' => (accessor => 'debug', is => 'rw', isa => 'Bool', default => 0, 
          documentation => 'Turns on debug mode');
  has 'p'  => (accessor => 'suppress_pager',  is => 'rw', isa => 'Bool', default => 0,
          documentation => 'Suppress use of a pager' );
  has 'r' => (accessor => 'suppress_readline', is => 'rw', isa => 'Bool', default => sub { ! -t STDIN },
          documentation => 'Suppress use of Term::ReadLine' );
  has 'f' => (accessor => 'config_file', is => 'rw', isa => 'Str', default => "$ENV{'HOME'}/.bamboorc",
          documentation => 'Use given rc file instead of ~/.bamboorc' );

  has '_prompt' => ( accessor => 'prompt', is => 'rw', isa => 'Str', default => 'bamboo>' );
  has '_in'     => ( accessor => 'IN', is => 'rw' );
  has '_out'    => ( accessor => 'OUT', is => 'rw' );
  has '_term'   => ( accessor => 'term', is => 'rw' );
  has '_sn'     => ( accessor => 'suppress_narrative', is => 'rw', isa => 'Bool' );
  has '_parser' => ( accessor => 'parser', is => 'rw', default => sub { Utukku::Engine::Parser -> new } );
  has '_context' => ( accessor => 'context', is => 'rw', default => sub { Utukku::Engine::Context -> new } );
  has '_silent' => (accessor => 'silent', is => 'rw', isa => 'Bool', default => 0 );
  has '_buffer' => (accessor => 'buffer', is => 'rw', isa => 'Str', default => '' );
  has '_line_no' => (accessor => 'line_no', is => 'rw', isa => 'Int', default => 1 );

  # used to manage the first word of a command
  has '_command_handlers' => (accessor => 'handlers', is => 'rw', isa => 'HashRef', default => sub { +{ } } );

  sub shell {
    Utukku::Shell -> new_with_options() -> run();
  }

  sub print {
    my($self, @stuff) = @_;
    return if $self -> silent;
    $self -> OUT -> print(@stuff);
  }

  sub run {
    my($self) = @_;

    if( $self -> help_flag ) {
      print $self -> usage, "\n";
      return;
    }

    # TODO: make these list objects
    $self -> context -> var('in', [ ] );
    $self -> context -> var('out', [ ] );

    $self -> suppress_narrative( scalar( @{$self -> extra_argv} ) > 0 );

    if( $self -> suppress_narrative ) {
      $self -> suppress_readline(1);
    }

    if( ! $self -> suppress_readline ) {
      eval { require Term::ReadLine; };
      $self -> suppress_readline(1) if $@;
    }

    if( $self -> suppress_readline ) {
      $self -> OUT(\*STDOUT);
      $self -> IN(\*STDIN);
    }
    else {
      $self -> term(Term::ReadLine -> new("Utukku Shell"))
        if( ! $self -> term
           or $self -> term -> ReadLine eq 'Term::Readline::Stub'
          );
      my $odef = select STDERR;
      $| = 1;
      select STDOUT;
      $| = 1;
      select $odef;
      $self -> OUT( $self -> term -> OUT || \*STDOUT );
      $self -> IN ( $self -> term -> IN  || \*STDIN  );
    }

    unless( $self -> suppress_narrative ) {
      $self -> print("\nbamboo shell -- Utukku (v$Utukku::VERSION)\n");
      $self -> print( "ReadLine support enabled\n") unless $self -> suppress_readline;
      $self -> print("Pager support enabled\n") unless $self -> suppress_pager;
    }

    eval {
      require Utukku::Shell::Base;
      #Utukku::Shell::Base -> init_commands($self);
    };

    $self -> find_commands('Utukku::Shell');

    unless( $self -> suppress_narrative ) {
      print "\n";
    }

    if( -f ($self -> config_file) && -r _ ) {
      $self -> print("Reading rc file ", $self -> config_file, "\n")
        unless $self -> suppress_narrative;
      $self -> read_file($self -> config_file);
    }

    if( $self -> suppress_readline ) {
      $self -> interpret($_) while(<>);
    }
    else {
      $self -> interpret($_)
        while defined($_ = $self -> term -> readline($self -> prompt));
    }

    if(! $self -> suppress_narrative ) {
      $self -> print("\n");
    }
  }

  sub add_handler {
    my($self, $prefix, $obj) = @_;

    $self -> handlers -> {$prefix} = $obj;
  }

  sub read_file {
    my($self, $file) = @_;

    if(-f $file && -r _) {
      my $fh;
      if(open $fh, "<", $file) {
        my $old_silent = $self -> silent;
        $self -> silent(1);
        while(<$fh>) {
          chomp;
          $self -> interpret($_);
        }
        $self -> silent($old_silent);
      }
    }
  }

  sub interpret {
    my($self, $line) = @_;

    if( $line =~ /^\\(.*)$/ ) {
      $self -> immediate($1);
    }
    else {
      $line = $self -> buffer . ' ' . $line;
      my $it = eval { $self -> parser -> parse($self -> context, $line, $self -> debug); };
      if( $@ =~ /Expected one of these terminals/ ) {
        # we save the text for later consideration
        if( $line =~ s/^.*?;//) { 
           # not perfect because the ; could be in a string
          warn "  $@\n";
        }
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        $self -> buffer($line);
        if( $self -> buffer eq '' ) {
          $self -> prompt("bamboo>");
        }
        else {
          $self -> prompt("bamboo...>");
        }
        return;
      }
      else {
        $self -> buffer('');
        $self -> prompt("bamboo>");
        if($@) {
          warn "  $@\n";
          return;
        }
      }

      if($it) {
        my $is_first = 1;
        my @subs = $it -> invert($self -> context, 0, {
          'next' => $self -> silent ? sub { } : sub { 
            if($is_first) {
              $self -> print("$_[0]");
              $is_first = 0;
            }
            else {
              $self -> print(", $_[0]");
            }
          },
          'done' => $self -> silent ? sub { } : sub {
             $self -> print("]\n");
          }
        });

        $self -> print('$in[', $self -> line_no, "] := $line\n");

        $self -> print('$out[', $self -> line_no, '] := [');
        $_ -> () for @subs;
      } else {
        unless($self -> suppress_narrative) {
          $self -> print("Error interpreting [$line]\n");
        }
        return;
      }


      $self -> print("OK\n");
      $self -> line_no( $self -> line_no + 1 );
    }
  }

  sub find_commands {
  }

  sub immediate {
    my($self, $command) = @_;

    my @bits = split(/\s+/, $command);
    if( $self -> handlers -> {$bits[0]} ) {
      $self -> handlers -> {shift @bits} -> immediate($self, @bits);
    }
    else {
      Utukku::Shell::Base -> instance -> immediate($self, @bits);
    }
  }

1;
