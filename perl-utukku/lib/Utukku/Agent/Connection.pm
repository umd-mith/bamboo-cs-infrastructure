package Utukku::Agent::Connection;
  use Moose;

  use Protocol::WebSocket::Handshake::Client;
  use Protocol::WebSocket::Frame;
  use JSON::XS;
  use Utukku::Engine::TagLib::Registry;

  use MooseX::Types::Moose qw(CodeRef);

  has url  => ( is => 'rw' );

  has client => ( is => 'rw', default => sub {
    Protocol::WebSocket::Handshake::Client -> new(
      url => $_[0] -> url
    );
  } );
  has server => ( is => 'rw' );
  has frame => ( is => 'rw', default => sub { Protocol::WebSocket::Frame -> new } );
  has namespaces => ( is => 'rw', default => sub { [ ] }, isa => 'ArrayRef' );

  sub initiate_handshake {
    my($self) = @_;

    if( !$self -> client -> is_done ) {
      $self -> server -> put($self -> client -> to_string);
    }
  }

=head2 new

 $connection = Utukku::Agent::Connection -> new(
   url => "...",
 );

=cut

 sub receive {
    my($self, $input) = @_;

    if( !$self -> client -> is_done ) {
      $self -> client -> parse($input);
      if( $self -> client -> is_done ) {
        #$self -> response({ class => 'declaration.agent', id => 0 });
        $self -> response({ class => 'flow.namespaces.register',
          data => Utukku::Engine::TagLib::Registry -> instance -> describe_namespaces(
                    @{$self -> namespaces}
                  )
        });
      }
      return;
    }

    $self -> frame -> append( $input );
  }

  sub next {
    my($self) = @_;
    my $n = $self -> frame -> next;
    return undef unless $n;

    return JSON::XS->new->utf8->decode($n);
  }

  sub encode {
    my($self, $json) = @_;

    return Protocol::WebSocket::Frame -> new(JSON::XS->new->utf8->encode($json)) -> to_string;
  }

  sub response {
    my($self, $response) = @_;

    $response -> {data} ||= {};

    $self -> server -> put($self -> encode($response));
  }
1;
