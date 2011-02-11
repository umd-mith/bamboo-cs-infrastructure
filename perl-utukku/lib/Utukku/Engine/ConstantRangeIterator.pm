package Utukku::Engine::ConstantRangeIterator;
  use Moose;
  extends 'Utukku::Engine::Iterator';

  has begin => ( is => 'ro' );
  has end   => ( is => 'ro' );
  has incr  => ( is => 'ro', default => 1 );

  sub start {
    my($self) = @_;

    my $i = Utukku::Engine::ConstantRangeIterator::Visitor -> new( 
      iterator => $self,
      increment => $self -> incr * (($self -> begin < $self -> end) ? 1 : -1),
    );
    $i -> start;
    return $i;
  }

  sub invert {
    my($self, $callbacks) = @_;

    my $visitor = $self -> start;

    sub {
      while(!$visitor -> at_end ) {
        $callbacks -> {'next'} -> ($visitor -> next);
      }
      $callbacks -> {'done'} -> ();
    }
  }
      

package Utukku::Engine::ConstantRangeIterator::Visitor;
  use Moose;

  use MooseX::Types::Moose qw(ArrayRef);
  use Utukku::Engine::Types qw(Iterator);

  has iterator => ( isa => Iterator, is => 'ro' );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has past_end => ( is => 'rw', default => 0 );
  has at_end   => ( is => 'rw', default => 0 );
  has increment => ( is => 'rw', default => 1 );

  sub start {
    my($self) = @_;
    $self -> value(undef);
  }

  sub next {
    my($self) = @_;
    if($self -> at_end) {
      $self -> past_end(1);
      $self -> value(undef);
    }
    elsif( !defined $self -> value ) {
      $self -> value( $self -> iterator -> begin );
      $self -> position(1);
      $self -> at_end( $self -> iterator -> begin == $self -> iterator -> end );
    }
    elsif( $self -> increment > 0 && $self -> value + $self -> increment <= $self -> iterator -> end 
        || $self -> increment < 0 && $self -> value + $self -> increment >= $self -> iterator -> end
    ) {
      $self -> value( $self -> value + $self -> increment );
      $self -> at_end(
        $self -> increment > 0 && $self -> value + $self -> increment > $self -> iterator -> end
        || $self -> increment < 0 && $self -> value + $self -> increment < $self -> iterator -> end
      );
      $self -> position( $self -> position + 1 );
    }
    else {
      $self -> at_end(1);
      $self -> value(undef);
    }
    return $self -> value;
  }

1;
