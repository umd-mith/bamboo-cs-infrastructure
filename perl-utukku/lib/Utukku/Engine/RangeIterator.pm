package Utukku::Engine::RangeIterator;
  use Moose;
  extends 'Utukku::Engine::Iterator';

  has begin => ( is => 'ro' );
  has end   => ( is => 'ro' );
  has incr  => ( is => 'ro', predicate => 'has_incr' );

  sub start {
    my($self) = @_;

    my $i = Utukku::Engine::RangeIterator::Visitor -> new( iterator => $self );
    $i -> start;
    return $i;
  }

  sub invert {
    my($self, $callbacks) = @_;

    my @sets = ( $self -> begin, $self -> end );
    push @sets, $self -> incr if $self -> has_incr;

    Utukku::Engine::SetIterator -> new(
      sets => \@sets,
      combinator => sub {
        my($left, $right, $incr) = (@_, 1);
        Utukku::Engine::ConstantRangeIterator -> new(
          begin => $left,
          end => $right,
          incr => $incr
        );
      }
    ) -> invert({
      'done' => $callbacks -> {done},
      'next' => sub {
        my($iterator) = @_;
        my @to_run = $iterator -> invert({
          'next' => $callbacks -> {next},
          'done' => sub { },
        });
        $_ -> () for @to_run;
      }
    });
  }

package Utukku::Engine::RangeIterator::Visitor;
  use Moose;

  use MooseX::Types::Moose qw(ArrayRef);
  use Utukku::Engine::Types qw(Iterator);

  use Utukku::Engine::ConstantRangeIterator;

  has iterator => ( isa => Iterator, is => 'ro' );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has past_end => ( is => 'rw', default => 0 );
  has at_end   => ( is => 'rw', default => 0 );
  has bounds_iterator => ( is => 'rw' );
  has bounds_visitor => ( is => 'rw' );

  sub start {
    my($self) = @_;
    my @sets = ( $self -> iterator -> begin, $self -> iterator -> end );
    push @sets, $self -> iterator -> incr if $self -> iterator -> has_incr;
    $self -> bounds_iterator(
      Utukku::Engine::SetIterator -> new(
        sets => \@sets,
        combinator => sub {
          my($left, $right, $incr) = (@_, 1);
          Utukku::Engine::ConstantRangeIterator -> new(
            begin => $left,
            end   => $right,
            incr  => $incr,
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
