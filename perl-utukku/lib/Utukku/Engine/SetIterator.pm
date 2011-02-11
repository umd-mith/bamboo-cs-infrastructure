package Utukku::Engine::SetIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

=head1 NAME

Utukku::Engine::Iterator

=head1 SYNOPSIS

 my $it = Utukku::Engine::SetIterator -> new(
   sets => ArrayRef of iterators,
   combinator => CodeRef of function to visit values
 );

 my $visitor = $it -> start;

 while(!$visitor -> at_end) {
   my $v = $visitor -> next;
   ...
 }

=head1 DESCRIPTION

=cut

  use MooseX::Types::Moose qw(ArrayRef CodeRef Bool);
  use Utukku::Engine::Types qw(Context);

  has sets => ( isa => ArrayRef, is => 'ro' );
  has combinator => ( isa => CodeRef, is => 'ro' );

=head2 start

 $visitor = $iterator -> start;

This returns a visitor that will step through the iterator, returning one
value at a time.

=cut

  sub invert {
    my($self, $callbacks) = @_;

    # TODO: be smarter about starting over with iterators
    $self -> _invert({
      done => $callbacks -> {done},
      next => sub {
        $callbacks -> {next} -> ($self -> combinator -> (@_));
      }
    }, @{$self -> sets});
  }

  sub _invert {
    my($self, $callbacks, $set, @sets) = @_;

    if(@sets > 0) {
      $set -> invert({
        done => $callbacks -> {done},
        next => sub {
          my($v) = @_;
          $_ -> () for $self -> _invert({
            done => sub { },
            next => sub {
              $callbacks -> {next} -> ($v, @_);
            }
          }, @sets);
        }
      });
    }
    else {
      $set -> invert($callbacks);
    }
  }

package Utukku::Engine::SetIterator::Visitor;
  use Moose;
  extends 'Utukku::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef);
  use Utukku::Engine::Types qw(Iterator);

  has sets => ( isa => ArrayRef, is => 'rw', default => sub { [ ] } );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has past_end => ( is => 'rw', default => 0 );

  sub start {
    my($self) = @_;

    $self -> sets( [ map { $_ -> start } @{$self -> iterator -> sets} ] );
    my @sets = @{$self -> sets};
    shift @sets;
    $_ -> next foreach @sets;
  }

  sub next {
    my($self) = @_;

    if( $self -> at_end ) {
      $self -> value(undef);
      $self -> past_end(1);
    }
    else {
      my($i, $n) = (0, $#{ $self -> sets });

      $self -> sets -> [0] -> next;
      while($i < $n && $self -> sets -> [$i] -> past_end) {
        $self -> sets -> [$i] = $self -> iterator -> sets -> [$i] -> start;
        $self -> sets -> [$i] -> next;
        if( $i < $n ) {
          $self -> sets -> [$i + 1] -> next;
        }
        $i += 1;
      }

      $self -> value( $self -> iterator -> combinator -> (
        map { $_ -> value } @{$self -> sets}
      ) );

      $self -> position( $self -> position + 1 );
    }

    return $self -> value;
  }

  sub at_end {
    my($self) = @_;

    return 0 == grep { !$_ -> at_end } @{$self -> sets};
  }

1;
