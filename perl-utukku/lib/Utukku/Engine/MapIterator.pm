package Utukku::Engine::MapIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

=head1 NAME

Utukku::Engine::MapIterator

=head1 SYNOPSIS

 my $it = Utukku::Engine::MapIterator -> new(
   iterator => iterator to be mapped,
   mapping  => sub { ... }
 );

 my $visitor = $it -> start;

 while(!$visitor -> at_end) {
   my $v = $visitor -> next;
   ...
 }

=head1 DESCRIPTION

=cut

  use MooseX::Types::Moose qw(CodeRef Bool);
  use Utukku::Engine::Types qw(Iterator Context);

  has iterator => ( isa => Iterator, is => 'ro' );
  has mapping  => ( isa => CodeRef,  is => 'ro' );

=head2 start

 $visitor = $iterator -> start;

This returns a visitor that will step through the iterator, returning one
value at a time.

=cut

  sub invert {
    my($self, $callbacks) = @_;

    $self -> iterator -> invert({
      done => $callbacks -> {done},
      next => sub {
        my $v = $self -> mapping -> ($_[0]);
        if( is_Iterator($v) ) {
          $_ -> () for @{$v -> invert({
            done => sub { },
            next => $callbacks -> {next},
          })};
        }
        else {
          $callbacks -> {next} -> ($v);
        }
      }
    });
  }

package Utukku::Engine::MapIterator::Visitor;
  use Moose;
  extends 'Utukku::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef Bool);
  use Utukku::Engine::Types qw(Iterator);

  has value => ( is => 'rw' );
  has position => ( is => 'rw', default => 0 );
  has at_end => (is => 'rw', default => 0);
  has past_end => (is => 'rw', default => 0);

## TODO: allow the mapping to return an iterator, and have us walk that
##       iterator instead of returning it

  has _visitor => ( is => 'rw');
  has _iterative_value => ( is => 'rw' );


  sub start {
    my($self) = @_;

    $self -> _visitor( $self -> iterator -> iterator -> start );
  }

  sub next {
    my($self) = @_;

    if( $self -> at_end ) {
      $self -> value(undef);
      $self -> past_end(1);
      return undef;
    }

    if( !$self -> _iterative_value || $self -> _iterative_value -> at_end ) {
      my $v = $self -> _visitor -> next;
      $v = $self -> iterator -> mapping -> ($v) if defined $v;
      if( is_Iterator($v) ) {
        $self -> _iterative_value($v -> start);
        $self -> value( $self -> _iterative_value -> next );
        $self -> position( $self -> position + 1 );
      }
      else {
        $self -> value($v);
        $self -> position( $self -> position + 1 );
      }
    }
    else {
      $self -> value( $self -> _iterative_value -> next );
      $self -> position( $self -> position + 1 );
    }

    if( $self -> _visitor -> at_end 
        && (!defined($self -> _iterative_value) 
             || $self -> _iterative_value -> at_end )) {
      $self -> at_end(1);
    }

    return $self -> value;
  }

1;
