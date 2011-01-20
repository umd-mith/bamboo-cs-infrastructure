package Bamboo::Engine::MapIterator;
  use Moose;

  extends 'Bamboo::Engine::Iterator';

=head1 NAME

Bamboo::Engine::MapIterator

=head1 SYNOPSIS

 my $it = Bamboo::Engine::MapIterator -> new(
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
  use Bamboo::Engine::Types qw(Iterator Context);

  has iterator => ( isa => Iterator, is => 'ro' );
  has mapping  => ( isa => CodeRef,  is => 'ro' );

=head2 start

 $visitor = $iterator -> start;

This returns a visitor that will step through the iterator, returning one
value at a time.

=cut

package Bamboo::Engine::MapIterator::Visitor;
  use Moose;
  extends 'Bamboo::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef Bool);
  use Bamboo::Engine::Types qw(Iterator);

  has value => ( is => 'rw' );

  has _visitor => ( 
    is => 'rw',
    handles => [qw( position at_end past_end )],
  );


  sub start {
    my($self) = @_;

    $self -> _visitor( $self -> iterator -> iterator -> start );
  }

  sub next {
    my($self) = @_;

    if( $self -> at_end ) {
      $self -> value(undef);
      $self -> past_end(1);
    }
    else {
      $self -> value( 
        $self -> iterator -> mapping -> ( $self -> _visitor -> next ) 
      );
    }

    return $self -> value;
  }

1;
