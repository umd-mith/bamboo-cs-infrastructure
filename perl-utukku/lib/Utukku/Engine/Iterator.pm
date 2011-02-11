package Utukku::Engine::Iterator;
  use Moose;

  sub start {
    my($self) = @_;
    my $visitor = ((ref $self) . '::Visitor') -> new( iterator => $self );
    $visitor -> start;

    return $visitor;
  }

  sub any {
    my($self, $code) = @_;

    my $visitor = $self -> start;

    my $v;

    until( $visitor -> at_end ) {
      $v = $visitor -> next;
      return 1 if $code -> ($v);
    }
    return 0;
  }

  sub all {
    my($self, $code) = @_;

    my $visitor = $self -> start;
    my $v;

    until( $visitor -> at_end ) {
      $v = $visitor -> next;
      return 0 unless $code -> ($v);
    }
    return 1;
  }


package Utukku::Engine::Iterator::Visitor;
  use Moose;

  use Utukku::Engine::Types qw( Iterator );

  has iterator => ( isa => Iterator, is => 'ro' );

  sub start {
  }

1;
