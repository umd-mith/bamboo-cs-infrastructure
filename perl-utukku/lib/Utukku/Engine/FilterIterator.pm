package Utukku::Engine::FilterIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

  use MooseX::Types::Moose qw(CodeRef Bool);
  use Utukku::Engine::Types qw(Iterator Context);

  has iterator => ( isa => Iterator, is => 'ro' );
  has filter   => ( isa => CodeRef,  is => 'ro' );

  sub build_async {
    my($self, $callbacks) = @_;

    $self -> iterator -> build_async({
      'done' => $callbacks -> {done},
      'next' => sub {
        if( $self -> filter -> ( $_[0] ) ) {
          $callbacks -> {'next'} -> ( $_[0] );
        }
      }
    });
  }

package Utukku::Engine::FilterIterator::Visitor;
  use Moose;
  extends 'Utukku::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef Bool);
  use Utukku::Engine::Types qw(Iterator);

  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has at_end => ( is => 'rw', default => 0, isa => Bool );
  has past_end => ( is => 'rw', default => 0, isa => Bool );
  has _next_value => ( is => 'rw' );
  has _visitor => ( is => 'rw' );

  sub start {
    my($self) = @_;

    $self -> _visitor( $self -> iterator -> iterator -> start );
    $self -> fetch_next;
  }

  sub fetch_next {
    my($self) = @_;

    if( $self -> _visitor -> at_end ) {
      $self -> _next_value(undef);
      return;
    }

    my $v;
    $v = $self -> _visitor -> next;
    while(!$self -> _visitor -> past_end && !$self -> iterator -> filter -> ($v)) {
      $v = $self -> _visitor -> next;
    }
    if( $self -> _visitor -> past_end ) {
      $self -> _next_value(undef);
      return;
    }
    $self -> _next_value($v);
  }

  sub next {
    my($self) = @_;

    if( $self -> at_end ) {
      $self -> value(undef);
      $self -> past_end(1);
    }
    elsif( $self -> _visitor -> at_end ) {
      $self -> at_end(1);
      $self -> value($self -> _next_value);
      $self -> position( $self -> position + 1 );
    }
    else {
      $self -> value($self -> _next_value);
      $self -> position( $self -> position + 1 );
      $self -> fetch_next;
      if( $self -> _visitor -> past_end ) {
        $self -> at_end(1);
      }
    }

    return $self -> value;
  }

1;
