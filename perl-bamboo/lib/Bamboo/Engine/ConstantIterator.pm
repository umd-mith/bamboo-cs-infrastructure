package Bamboo::Engine::ConstantIterator;
  use Moose;
  extends 'Bamboo::Engine::Iterator';

  use MooseX::Types::Moose qw(ArrayRef);

  has values => ( isa => ArrayRef, is => 'ro' );

  sub start {
    my($self) = @_;

    return Bamboo::Engine::ConstantIterator::Visitor -> new( iterator => $self );
  }

package Bamboo::Engine::ConstantIterator::Visitor;
  use Moose;

  use MooseX::Types::Moose qw(ArrayRef);
  use Bamboo::Engine::Types qw(Iterator);

  has iterator => ( isa => Iterator, is => 'ro' );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has past_end => ( is => 'rw', default => 0 );

  sub next {
    my($self) = @_;
    if($self -> at_end) {
      $self -> past_end(1);
      $self -> value(undef);
    }
    else {
      $self -> position($self -> position + 1);
      $self->value($self -> iterator -> values -> [$self -> position - 1]);
    }
    return $self -> value;
  }

  sub at_end {
    my($self) = @_;
    $self -> position > $#{$self -> iterator -> values};
  }

1;
