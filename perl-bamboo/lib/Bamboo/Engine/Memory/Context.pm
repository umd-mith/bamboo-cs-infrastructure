package Bamboo::Engine::Memory::Context;
  use Moose;

  use Bamboo::Engine::Memory::Node;

  use Bamboo::Engine::Types qw( Node Context );
  use MooseX::Types::Moose qw( HashRef Int Bool );

  has node => ( is => 'rw', isa => Node );

  has parent => ( is => 'rw', isa => Context );
  has runtime_parent => ( is => 'rw', isa => Context );

  has ns => ( is => 'rw', isa => HashRef, default => sub { +{ } } );
  has _position => ( is => 'rw', isa => 'Maybe[Int]', default => undef );
  has _last => ( is => 'rw', isa => 'Maybe[Bool]', default => undef );

  around new => sub {
    my $orig  = shift;
    my $class = shift;
    my %args  = @_;

    my $self = $class->$orig(@_);

    if( !$args{parent} ) {
      # TODO: look to any XML context info
    }
    $self;
  };

  sub add_ns {
    my($self, $p, $ns) = @_;

    $self -> ns -> { $p } = $ns;
  }

  sub last {
    my($self) = @_;

    if( @_ == 1 ) {
      return $self -> _last if defined $self -> _last;
      return undef unless defined $self -> runtime_parent;
      return $self -> runtime_parent -> last;
    }
    else {
      $self -> _last($_[1]);
    }
  }

  sub position {
    my($self) = @_;

    if( @_ == 1 ) {
      return $self -> _position if defined $self -> _position;
      return undef unless defined $self -> runtime_parent;
      return $self -> runtime_parent -> position;
    }
    else {
      $self -> _position($_[1]);
    }
  }

=head2 with_node

 $context -> with_node( $node, sub {
    my($context) = @_;

    # ... do stuff with new node
 } );

This method will call the code with a new context object that holds the given
node as the current relative memory location.  This construct allows the
child context to be destroyed automatically when the code finishes.

=cut

  sub with_node {
    my($self, $node, $code) = @_;

    $code -> ( $self -> new(
      parent => $self,
      node => $node,
    ) );
  }
  
1;
