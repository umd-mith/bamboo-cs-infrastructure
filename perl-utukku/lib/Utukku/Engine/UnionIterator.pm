package Utukku::Engine::UnionIterator;
  use Moose;

  extends 'Utukku::Engine::Iterator';

  use MooseX::Types::Moose qw(ArrayRef CodeRef Bool);
  use Utukku::Engine::Types qw(Context);

  has iterators => ( isa => ArrayRef, is => 'ro' );

  sub build_async {
    my($self, $callbacks) = @_;

    my $done;
    my $next_callbacks = {
      'next' => $callbacks -> {'next'},
      'done' => sub {
                  $done += 1;
                  if( $done >= @{$self -> iterators} ) {
                    $callbacks -> {done} -> ();
                  }
                },
    };

    map { $_ -> build_async($next_callbacks) } @{$self -> iterators};
  }

package Utukku::Engine::UnionIterator::Visitor;
  use Moose;
  extends 'Utukku::Engine::Iterator::Visitor';

  use MooseX::Types::Moose qw(ArrayRef Bool);
  use Utukku::Engine::Types qw(Iterator);

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
