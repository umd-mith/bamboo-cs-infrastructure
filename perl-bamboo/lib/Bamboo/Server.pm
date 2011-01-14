package Bamboo::Server;
  use Moose;

  use Bamboo::Server::Connection;

  use POE qw(Component::Server::TCP);

  has _was_setup => ( is => 'rw', default => 0 );

  has port => ( is => 'rw', default => 3000 );
  has agents => ( is => 'rw', default => sub { [ ] } );
  has queries => ( is => 'rw', default => sub { +{ } } );

  sub setup {
    my($self) = @_;

    POE::Component::Server::TCP -> new(
      Port => $self -> port,
      ClientFilter => 'POE::Filter::Stream',
      ClientConnected => sub {
        $_[HEAP]{websocket} = Bamboo::Server::Connection -> new( client => $_[HEAP]{client} );
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
      InlineStates => {
        message => sub {
          my($msg) = $_[ARG0];
          if($_[HEAP]{is_agent}) {
            if( $msg -> {id} ) {
              # send response to client
              my $client = $self -> id_to_client($msg -> {id});
              if( $client ) {
                $client -> send({ class => $msg->{class}, data => $msg->{data}, id => $msg->{id}});
              }
            }
          }
          elsif( $msg -> {class} eq 'declaration.agent' ) {
            # registering an agent
            $self -> register_agent($_[HEAP]{websocket}, $msg -> {data});
            $_[HEAP]{is_agent} = 1;
          }
          elsif( $msg -> {class} eq 'declaration.query.done' ) {
            $self -> unregister_query($_[HEAP]{websocket}, $msg -> {id});
          }
          else { # it's a client sending a request
            $self -> register_query($_[HEAP]{websocket}, $msg -> {id});
            $self -> broadcast( $msg );
          }
          print STDERR "class: " . $msg -> {class} . "\n";
          print STDERR "id: " . $msg -> {id} . "\n";
        }
      },
    );

printf STDERR "We're set up\n";
    $self -> _was_setup(1);
    #POE::Kernel -> run;
  }

  sub register_query {
    my($self, $client, $id) = @_;

    $self -> queries -> {$id} = $client;
  }

  sub unregister_query {
    my($self, $client, $id) = @_;

    if($self -> queries -> {$id} eq $client) {
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

  sub unregister_client {
    my($self, $client) = @_;

    delete @{$self -> queries}{grep { $self -> queries -> {$_} eq $client } keys %{$self -> queries}};
  }

  sub broadcast {
    my($self, $msg) = @_;

    for my $agent (@{$self -> agents}) {
      $agent -> send($msg);
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

Bamboo::Server - Provides a simple Bamboo Corpora Space switchboard

=head1 SYNOPSIS

 use Bamboo::Server;

 Bamboo::Server -> new(
   port => 3000
 ) -> run;

=head1 DESCRIPTION

Bamboo::Server uses POE to enable asynchronous interaction with clients and
agents in the Bamboo Corpora Space infrastructure.

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
