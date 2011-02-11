package Utukku::Engine::ReductionIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

=head1 NAME

Utukku::Engine::ReductionIterator

=head1 SYNOPSIS

 my $it = Utukku::Engine::ReductionIterator -> new(
   iterator => iterator to be reduced,
   reduction  => sub { +{
     next => sub { },
     done => sub { }
   } }
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

  has iterator  => ( isa => Iterator, is => 'ro' );
  has reduction => ( isa => CodeRef,  is => 'ro' );

=head2 start

 $visitor = $iterator -> start;

This returns a visitor that will step through the iterator, returning one
value at a time.

=cut

  sub invert {
    my($self, $callbacks) = @_;

    my $reducers = $self -> reduction -> ();

    $self -> iterator -> invert({
      done => sub { 
        my $r = $reducers -> {done} -> ();
        if(is_Iterator($r)) {
          $_ -> () for $r -> invert($callbacks);
        }
        else {
          $callbacks -> {next} -> ($r);
          $callbacks -> {done} -> ();
        }
      },
      next => sub {
        $reducers -> {next} -> ($_[0]);
      }
    });
  }

  sub start {
    my($self) = @_;

    my $v = $self -> iterator -> start;
    my $reducers = $self -> reduction -> ();
    while(!$v -> at_end) {
      $reducers -> {next} -> ($v -> next);
    }
    $v = $reducers -> {done} -> ();
    if(is_Iterator($v)) {
      return $v -> start;
    }
    else {
      return Utukku::Engine::ConstantIterator -> new(
        values => [ $v ],
      ) -> start;
    }
  }
      
1;
