package Bamboo::Agent;
  use Moose;

  use MooseX::Types::Moose qw(HashRef CodeRef);

  use Bamboo::Agent::Connection;
  use URI;
  use JSON::XS;

  use POE qw(Component::Client::TCP);

  has _was_setup => ( is => 'rw', default => 0 );

  has url => ( is => 'rw', default => 'http://localhost:3000/demo' );
  has alias => ( is => 'rw', default => 'agent' );
  has connection => ( is => 'rw' );
  has events => ( is => 'rw', isa => HashRef, default => sub { +{ } } );

  sub setup {
    my($self) = @_;

    my $uri = URI -> new($self -> url);
    my $ws_uri = $self -> url;
    $ws_uri =~ s/^https?:/ws:/;

    POE::Component::Client::TCP -> new(
      Alias => $self -> alias,
      RemoteAddress => $uri -> host,
      RemotePort => $uri -> port,
      Filter => 'POE::Filter::Stream',
      Connected => sub {
        $self -> connection(Bamboo::Agent::Connection -> new(
          server => $_[HEAP]{server},
          url => $ws_uri,
        ));
        $self -> connection -> initiate_handshake;
      },
      ServerInput => sub {
        $self -> connection -> receive($_[ARG0]);
        my $msg;
        while( $msg = $self -> connection -> next ) {
          $_[KERNEL] -> yield('message', $msg);
        }
      },
      Disconnected => sub {
        $_[KERNEL] -> delay( reconnect => 60 );
      },
      InlineStates => {
        message => sub {
          $self -> message($_[ARG0]);
        }
      },
    );

    $self -> _was_setup(1);
  }

  sub message {
    my($self, $msg) = @_;

    my $k = $msg -> {class};
    while( $k =~ /\./ && !defined $self -> events -> {$k} ) {
      $k =~ s/\.[^.]+$//;
    }
    my $h = $self -> events -> {$k};
    return unless defined $h;

    if( is_CodeRef($h) ) {
      $h -> ($msg -> {class}, $msg -> {data}, $msg -> {id});
    }
    else {
      $self -> $h($msg -> {class}, $msg -> {data}, $msg -> {id});
    }
  }

  sub response {
    my($self, $class, $data, $id) = @_;

    if( $self -> connection ) {
       $self -> connection -> response({ class => $class, data => $data, id => $id });
    }
    else {
      push @{$self -> _queue}, { class => $class, data => $data, id => $id };
    }
  }

  sub clear_queue {
    my($self) = @_;

    if( $self -> connection ) {
      $self -> request($_->{'class'}, $_->{'data'}) for @{$self -> _queue};
    }
  }

  sub run {
    my($self) = @_;

    $self -> setup unless $self -> _was_setup;

    POE::Kernel -> run();
  }

1;

__END__

=head1 NAME

Bamboo::Agent - Scaffolding for building a Bamboo agent

=head1 SYNOPSIS

 $agent = Bamboo::Agent -> new(
   url => 'http://localhost:3000/demo',
   events => {
     'echo' => sub {
       my($class, $data, $id) = @_;
       $agent -> response($class, $data, $id);
     }
   }
  );

  $agent -> run;

=head1 DESCRIPTION

The Bamboo::Agent uses POE to enable asynchronous interaction with the
Bamboo Corpora Space infrastructure.

=head1 EVENTS

Events consist of an event class, event data, and an event id.

Event classes are heirarchical.  For example, a handler for 'foo.bar' will
not receive events for 'foo', but will for 'foo.bar' and 'foo.bar.baz'.

=head2 Event Classes

=over 4

=item declaration.agent

An event with this class is sent automatically when connecting to a
server.  This notifies the server that this connection is to an agent.

=back
