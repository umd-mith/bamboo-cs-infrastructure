package Utukku::Server;
  use Moose;
  with 'MooseX::Getopt';
  with 'MooseX::SimpleConfig';

  use Utukku::Server::Connection;

  use POE qw(Component::Server::TCP);


  has port => ( is => 'rw', default => 3000, isa => 'Int',
        documentation => 'Port on which to listen for connections.' );
  has namespace => ( is => 'rw', isa => 'HashRef', default => sub { +{ } } );
  has '+configfile' => ( default => 'bamboo.conf', 
        documentation => 'Configuration file.' );

  has _agents => ( accessor => 'agents', is => 'rw', default => sub { [ ] } );
  has _clients => ( accessor => 'clients', is => 'rw', default => sub { [ ] } );
  has _queries => ( accessor => 'queries', is => 'rw', default => sub { +{ } } );
  has _was_setup => ( is => 'rw', default => 0 );

  sub config_any_args {
    +{
      driver_args => {
        General => {
          -ApacheCompatible => 1,
          -LowerCaseNames => 1,
          -AutoTrue => 1,
        }
      },
    }
  }

  sub setup {
    my($self) = @_;

    POE::Component::Server::TCP -> new(
      Port => $self -> port,
      ClientFilter => 'POE::Filter::Stream',
      ClientConnected => sub {
        $_[HEAP]{websocket} = Utukku::Server::Connection -> new( client => $_[HEAP]{client}, server => $self );
      },
      ClientDisconnected => sub {
        if( $_[HEAP]{is_agent} ) {
          $self -> unregister_agent($_[HEAP]{websocket});
        }
        else {
          $self -> unregister_client($_[HEAP]{websocket});
        }
      },
      ClientInput => sub {
        $_[HEAP]{websocket} -> process_input($_[ARG0]);
        my $msg;
        while( $msg = $_[HEAP]{websocket} -> next ) {
          $_[KERNEL] -> yield('message', $msg);
        }

      },

## TODO: remap message ids between clients and agents so each client has its
##       own msg id space.  This keeps clients from stomping on each other.

      InlineStates => {
        message => sub {
          my($msg) = $_[ARG0];
          if($_[HEAP]{is_agent}) {
            $self -> agent_handler($_[HEAP]{websocket}, $msg);
          }
## we become an agent if we export a namespace of functionality
          elsif( $msg -> {class} eq 'flow.namespaces.register' ) {
            # registering an agent
            my $agent = $_[HEAP]{websocket};

            $self -> unregister_client($agent);
            $self -> register_agent($agent, $msg -> {data});
            $_[HEAP]{is_agent} = 1;

            $agent -> register_namespaces($msg->{data});

            $self -> broadcast_clients({
              class => 'flow.namespace.registered',
              data => $self -> namespaces
            });
          }
          else {
            $self -> client_handler($_[HEAP]{websocket}, $msg);
          }

        }
      },
    );

use Data::Dumper;
    $self -> _was_setup(1);
  }

  sub agent_handler {
    my($self, $agent, $msg) = @_;

    if( $msg -> {id} ) {
      # send response to client
      my $client = $self -> id_to_client($msg -> {id});
      if( $client && $client -> {client} ) {
        $client -> {client} -> send($msg);
      }
      else {
        print STDERR "Uh oh - problem with the message ", $msg->{id}, "\n";
print STDERR Data::Dumper -> Dump([$client]);
      }
    }
  }

  sub client_handler {
    my($self, $client, $msg) = @_;

    if( $msg -> {class} eq 'declaration.query.done' ) {
      $self -> unregister_query($client, $msg -> {id});
    }
    elsif( $msg -> {class} eq 'flow.create' ) {
      # we can restrict agent broadcast to those which registered
      #  the namespace
      # We want to record which agents get the flow.create so we
      #  can pass along other flow.* from clients with the same id
      my $agents = $self -> broadcast( $msg );
      $self -> register_query($client, $msg -> {id}, $agents);
    }
    elsif( $msg -> {class} eq 'flow.close' ) {
      $self -> narrow_broadcast( $msg );
      $self -> unregister_query($client, $msg -> {id});
    }
    elsif( $msg -> {class} =~ /^flow\.provided?/ ) {
      $self -> narrow_broadcast( $msg );
    }
    else { # it's a client sending a request
      $self -> register_query($client, $msg -> {id});
      $self -> broadcast( $msg );
    }
  }

  sub register_query {
    my($self, $client, $id, $agents) = @_;

    return unless $id;

    $self -> queries -> {$id} = { client => $client, agents => $agents };
  }

  sub unregister_query {
    my($self, $client, $id) = @_;

    return unless $id;

    if($self -> queries -> {$id} -> {client} eq $client) {
      delete ${$self -> queries}{$id};
    }
  }

  sub id_to_client {
    my($self, $id) = @_;

    $self -> queries -> {$id};
  }

  sub register_agent {
    my($self, $agent) = @_;

    push @{$self -> agents}, $agent;
  }

  sub unregister_agent {
    my($self, $agent) = @_;

    $self -> agents( [ grep { $_ ne $agent } @{$self -> agents} ] );
  }

  sub register_client {
    my($self, $client) = @_;

    push @{$self -> clients}, $client;
  }

  sub unregister_client {
    my($self, $client) = @_;

    delete @{$self -> queries}{grep { $self -> queries -> {$_} eq $client } keys %{$self -> queries}};
    $self -> clients( [ grep { $_ ne $client } @{$self -> clients} ] );
  }

  sub namespaces {
    my($self) = @_;

    my %namespaces;

    for my $a (@{$self -> agents}) {
      for my $ns ( keys %{$a -> namespaces} ) {
        next if defined $namespaces{$ns};
        $namespaces{$ns} = $a -> namespaces -> {$ns};
      }
    }

    \%namespaces;
  }

  sub broadcast {
    my($self, $msg) = @_;

    my @agents;
    for my $agent (@{$self -> agents}) {
      $agent -> send($msg);
      push @agents, $agent;
    }
    return \@agents;
  }

  sub narrow_broadcast {
    my($self, $msg) = @_;

    my $agents = $self -> queries -> {$msg -> {id}} -> {agents} || [];

    for my $agent (@$agents) {
      eval { $agent -> send($msg) }; # in case they've disconnected
print STDERR "Un oh: $@\n" if $@;
    }
  }

  sub broadcast_clients {
    my($self, $msg) = @_;

    for my $client (@{$self -> clients}) {
      $client -> send($msg);
    }
  }

  sub run {
    my($self) = @_;

    $self -> setup unless $self -> _was_setup;

    POE::Kernel -> run;
  }

1;

__END__

=head1 NAME

Utukku::Server - Provides a simple Utukku Corpora Space switchboard

=head1 SYNOPSIS

 use Utukku::Server;

 Utukku::Server -> new(
   port => 3000
 ) -> run;

=head1 DESCRIPTION

Utukku::Server uses POE to enable asynchronous interaction with clients and
agents in the Utukku Corpora Space infrastructure.

=head1 EVENTS

The server responds to the following event classes.

=over 4

=item declaration.agent

The server will mark the connection as being an agent instead of a client.

=item declaration.query.done

The server will remove any saved state for the id associated with this event.
Any responses received from agents after this event will be discarded.  This
event may be propagated to agents.

=back
