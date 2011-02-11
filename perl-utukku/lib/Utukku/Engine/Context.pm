package Utukku::Engine::Context;
  use Moose;

  use Utukku::Engine::Memory::Node;
  use Utukku::Engine::TagLib::Registry;

  use Utukku::Engine::Types qw( Node Context );
  use MooseX::Types::Moose qw( HashRef Int Bool );

  has node => ( is => 'rw', isa => Node );

  has parent => ( is => 'rw', isa => Context );
  has runtime_parent => ( is => 'rw', isa => Context );

  has _ns => ( is => 'rw', isa => HashRef, default => sub { +{ } } );
  has _position => ( is => 'rw', isa => 'Maybe[Int]', default => undef );
  has _last => ( is => 'rw', isa => 'Maybe[Bool]', default => undef );
  has _vars => ( is => 'rw', isa => 'HashRef', default => sub { +{ } } );

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

  sub ns {
    my($self, $p, $ns) = @_;

    if( @_ == 2 ) {
      return $self -> _ns -> { $p } if exists $self->_ns->{$p};
      return undef unless $self -> parent;
      return $self -> parent -> ns($p);
    }
    else {
      $self -> _ns -> { $p } = $ns;
    }
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

  sub var {
    my($self, $name, $iter) = @_;

    if( @_ > 2 ) {
      $self -> _vars -> {$name} = $iter;
    }
    else {
      return $self -> _vars -> {$name} if exists $self -> _vars -> {$name};
      return Utukku::Engine::NullIterator -> new 
        unless defined $self -> runtime_parent;
      return $self -> runtime_parent -> var($name);
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

  sub with_ctx {
    my($self, $ctx, $code) = @_;

    $code -> ( $self -> new(
      parent => $self,
      runtime_parent => $ctx
    ) );
  }
  
  sub function_to_iterator {
    my($self, $nom, $args) = @_;

    # find handler, then pass off to handler for iterator construction
    my($prefix, $name) = split(/:/, $nom, 2);
    my $ns = $self -> ns($prefix);

    my $handler = Utukku::Engine::TagLib::Registry -> instance -> handler($ns);

    return Utukku::Engine::NullIterator -> new unless $handler;

    $handler -> function_to_iterator($name, $args);
  }

1;
