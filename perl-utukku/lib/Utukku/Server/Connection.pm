package Utukku::Server::Connection;
  use Moose;

  use Protocol::WebSocket::Handshake::Server;
  use Protocol::WebSocket::Frame;
  use JSON::XS;

  has handshake => ( is => 'rw', default => sub { Protocol::WebSocket::Handshake::Server -> new } );
  has server => ( is => 'rw', isa => 'Utukku::Server', required => 1 );
  has client => ( is => 'rw' );
  has frame  => ( is => 'rw', default => sub { Protocol::WebSocket::Frame -> new } );
  has namespaces => ( is => 'rw', default => sub { +{ } }, isa => 'HashRef' );

  sub process_input {
    my($self, $chunk) = @_;

#print STDERR "input: [$chunk]\n";
    if( !$self -> handshake -> is_done ) {
      $self -> handshake -> parse($chunk);
      if( $self -> handshake -> error ) {
      }
      if( $self -> handshake -> is_done ) {
        $self -> client -> put( $self -> handshake -> to_string );

        $self -> send({
          class => 'flow.namespaces.registered',
          data => $self -> server -> namespaces
        });
# here we can put initial client initialization stuff, like available
# tag library services
      }
      return;
    }

    return unless defined $chunk;

    $self -> frame -> append( $chunk );
  }

  sub next {
    my($self) = @_;
    my $n = $self -> frame -> next;
    return undef unless defined $n;

    return JSON::XS->new->utf8->decode($n);
  }

  sub encode {
    my($self, $json) = @_;

    return Protocol::WebSocket::Frame->new(JSON::XS->new->utf8->encode($json)) -> to_string;
  }

  sub send {
    my($self, $request) = @_;

    $self -> client -> put($self -> encode($request));
  }

  sub register_namespaces {
    my($self, $spaces) = @_;

    for my $ns (keys %$spaces) {
      $self -> namespaces -> {$ns} = $spaces -> {$ns};
    }
  }

1;

__END__
