package Bamboo::Engine::RangeIterator;
  use Moose;
  extends 'Bamboo::Engine::Iterator';

  has begin => ( is => 'ro' );
  has end   => ( is => 'ro' );

  sub start {
    my($self) = @_;

    my $i = Bamboo::Engine::RangeIterator::Visitor -> new( iterator => $self );
    $i -> start;
    return $i;
  }

package Bamboo::Engine::RangeIterator::Visitor;
  use Moose;

  use MooseX::Types::Moose qw(ArrayRef);
  use Bamboo::Engine::Types qw(Iterator);

  use Bamboo::Engine::ConstantRangeIterator;

  has iterator => ( isa => Iterator, is => 'ro' );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has past_end => ( is => 'rw', default => 0 );
  has at_end   => ( is => 'rw', default => 0 );
  has bounds_iterator => ( is => 'rw' );
  has bounds_visitor => ( is => 'rw' );

  sub start {
    my($self) = @_;
    $self -> bounds_iterator(
      Bamboo::Engine::SetIterator -> new(
        sets => [ $self -> iterator -> begin, $self -> iterator -> end ],
        combinator => sub {
          my($left, $right) = @_;
          Bamboo::Engine::ConstantRangeIterator -> new(
            begin => $left,
            end   => $right
          ) -> start;
        }
      ) -> start
    );
    $self -> bounds_visitor($self -> bounds_iterator -> next);
  }

  sub next {
    my($self) = @_;
    if($self -> at_end) {
      $self -> past_end(1);
      $self -> value(undef);
    }
    else {
      $self -> bounds_visitor -> next;
      if( $self -> bounds_visitor -> past_end ) {
        $self -> bounds_visitor($self -> bounds_iterator -> next);
        $self -> bounds_visitor -> next;
      }
      $self -> value( $self -> bounds_visitor -> value );
      $self -> position($self -> position + 1);
    }
    if($self -> bounds_visitor -> at_end && 
       $self -> bounds_iterator -> at_end) {
      $self -> at_end(1);
    }
    return $self -> value;
  }

1;
