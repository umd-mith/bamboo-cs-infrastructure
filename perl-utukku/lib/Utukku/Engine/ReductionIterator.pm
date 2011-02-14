package Utukku::Engine::ReductionIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

  use MooseX::Types::Moose qw(CodeRef Bool HashRef);
  use Utukku::Engine::Types qw(Iterator Context);

  has iterator  => ( isa => Iterator, is => 'ro' );
  has reduction => ( isa => 'HashRef|CodeRef',  is => 'ro', default => sub { +{ init => sub { }, next => sub { }, done => sub { } } } );

  sub build_async {
    my($self, $callbacks) = @_;

    my $reducers = is_CodeRef($self -> reduction) ? $self -> reduction -> () : $self -> reduction;
    my $pad = ($reducers -> {init} || sub { } ) -> ();

    $self -> iterator -> build_async({
      done => sub { 
        my $r = $reducers -> {done} -> ($pad);
        if(is_Iterator($r)) {
          $r -> async($callbacks);
        }
        else {
          $callbacks -> {next} -> ($r);
          $callbacks -> {done} -> ();
        }
      },
      next => sub {
        $pad = $reducers -> {next} -> ($pad, $_[0]);
      }
    });
  }

  sub start {
    my($self) = @_;

    my $v = $self -> iterator -> start;
    my $reducers = is_CodeRef($self -> reduction) ? $self -> reduction -> () : $self -> reduction;
    my $pad = $self -> reduction -> {init} -> ();
    while(!$v -> at_end) {
      $pad = $reducers -> {next} -> ($pad, $v -> next);
    }
    $v = $reducers -> {done} -> ($pad);
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
