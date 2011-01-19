package Bamboo::Engine::UnionIterator;
  use Moose;

  extends 'Bamboo::Engine::Iterator';

=head1 NAME

Bamboo::Engine::UnionIterator

=head1 SYNOPSIS

 my $it = Bamboo::Engine::UnionIterator -> new(
   sets => ArrayRef of iterators,
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

  has iterators => ( isa => ArrayRef, is => 'ro' );

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

package Bamboo::Engine::UnionIterator::Visitor;
  use Moose;
  extends 'Bamboo::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef Bool);
  use Bamboo::Engine::Types qw(Iterator);

  has iterators => ( isa => ArrayRef, is => 'rw', default => sub { [ ] } );
  has position => ( is => 'rw', default => 0 );
  has value => ( is => 'rw' );
  has at_end => ( is => 'rw', default => 0, isa => Bool );
  has past_end => ( is => 'rw', default => 0, isa => Bool );

  sub start {
    my($self) = @_;

    $self -> iterators( [ map { $_ -> start } @{$self -> iterator -> iterators} ] );
  }

  sub next {
    my($self) = @_;

    if( $self -> at_end ) {
      $self -> value(undef);
      $self -> past_end(1);
    }
    else {
      my($i, $n) = (0, $#{ $self -> iterators });

      $self -> value($self -> iterators -> [0] -> next);
      if( $self -> iterators -> [0] -> at_end ) {
        shift @{$self -> iterators};
        if( @{$self -> iterators} == 0 ) {
          $self -> at_end(1);
        }
      }

      $self -> position( $self -> position + 1 );
    }

    return $self -> value;
  }

1;
