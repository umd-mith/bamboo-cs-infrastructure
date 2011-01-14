package Bamboo::Client::Connection;
  use Moose;

  use Protocol::WebSocket::Handshake::Client;
  use Protocol::WebSocket::Frame;
  use JSON::XS;

  use MooseX::Types::Moose qw(CodeRef);

  has url  => ( is => 'rw' );

  has client => ( is => 'rw', default => sub {
    Protocol::WebSocket::Handshake::Client -> new(
      url => $_[0] -> url
    );
  } );
  has server => ( is => 'rw' );
  has frame => ( is => 'rw', default => sub { Protocol::WebSocket::Frame -> new } );


  sub initiate_handshake {
    my($self) = @_;

    if( !$self -> client -> is_done ) {
      $self -> server -> put($self -> client -> to_string);
    }
  }

  sub receive {
    my($self, $input) = @_;

    if( !$self -> client -> is_done ) {
      $self -> client -> parse($input);
      if( $self -> client -> is_done ) {
        POE::Kernel -> yield("clear_queue");
      }
      return;
    }

    $self -> frame -> append( $input );
  }

  sub next {
    my($self) = @_;
    my $n = $self -> frame -> next;
    return unless defined $n;

    return JSON::XS->new->utf8->decode($n);
  }

  sub encode {
    my($self, $json) = @_;

    return Protocol::WebSocket::Frame -> new(JSON::XS->new->utf8->encode($json)) -> to_string;
  }

  sub request {
    my($self, $request) = @_;

    $self -> server -> put($self -> encode($request));
  }

1;

__END__

=head1 NAME

Bamboo::Client::Protocol - handles the low-level protocol issues

=head1 SYNOPSIS

 my $con = Bamboo::Client::Connection -> new(
   server => $poe_tcp_server,
   url => $url
 );

 $con -> initiate_handshake;

 $con -> receive($text);

 while( $msg = $con -> next ) {
   # ... do something with $msg
 }

=head1 DESCRIPTION

This module handles the low-level details of the protocol given a server
connection that looks like that provided by L<POE::Component::Client::TCP>.

Typically, you won't use this module directly.  It is designed to be used by
L<Bamboo::Client>.
