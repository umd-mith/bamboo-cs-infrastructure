package Bamboo::Engine::SetIterator;
  use Moose;

  extends 'Bamboo::Engine::Iterator';

=head1 NAME

Bamboo::Engine::Iterator

=head1 SYNOPSIS

 my $it = Bamboo::Engine::SetIterator -> new(
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
  use Bamboo::Engine::Types qw(Context);

  has sets => ( isa => ArrayRef, is => 'ro' );
  has combinator => ( isa => CodeRef, is => 'ro' );

=head2 start

 $visitor = $iterator -> start;

This returns a visitor that will step through the iterator, returning one
value at a time.

=cut

#  sub start {
#    my($self) = @_;
#    my $visitor = Bamboo::Engine::SetIterator::Visitor -> new( iterator => $self );
#    $visitor -> start;
#
#    return $visitor;
#  }

package Bamboo::Engine::SetIterator::Visitor;
  use Moose;
  extends 'Bamboo::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef);
  use Bamboo::Engine::Types qw(Iterator);

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
