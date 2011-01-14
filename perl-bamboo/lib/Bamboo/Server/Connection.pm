package Bamboo::Server::Connection;
  use Moose;

  use Protocol::WebSocket::HandShake::Server;
  use Protocol::WebSocket::Frame;
  use JSON::XS;

  has server => ( is => 'rw', default => sub { Protocol::WebSocket::Handshake::Server -> new } );
  has client => ( is => 'rw' );
  has frame  => ( is => 'rw', default => sub { Protocol::WebSocket::Frame -> new } );

  sub process_input {
    my($self, $chunk) = @_;

    if( !$self -> server -> is_done ) {
      $self -> server -> parse($chunk);
      if( $self -> server -> error ) {
      }
      if( $self -> server -> is_done ) {
        $self -> client -> put( $self -> server -> to_string );

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

1;

__END__
