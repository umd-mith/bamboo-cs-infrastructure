package Utukku::Engine::Iterator;
  use Moose;
  use Carp;

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

  sub invert {
    my $self = shift;
    carp "Deprecated use of invert";
    $self -> build_async(@_);
  }

  sub build_async {
    my $class = ref $_[0] || $_[0];
    croak "build_async is unimplemented for $class"
  }

  sub async {
    my $self = shift;
    my @subs = $self -> build_async(@_);
    $_->() for @subs;
  }

package Utukku::Engine::Iterator::Visitor;
  use Moose;
  use Carp;

  use Utukku::Engine::Types qw( Iterator );

  has iterator => ( isa => Iterator, is => 'ro' );


  for my $sub (qw[ start next value at_end past_end ]) {
    no strict 'refs';
    *{$sub} = sub {
      my $class = ref $_[0] || $_[0];
      croak "$sub is unimplemented for $class";
    };
  }

1;

__END__

=head1 NAME

Utukku::Engine::Iterator - base class for iterators

=head1 SYNOPSIS

 package MyIterator;
   use Moose;
   extends 'Utukku::Engine::Iterator';

   sub build_async {
     my($self, $callbacks) = @_;

     # code to provide asynchronous traversal of the iterator
     # returns a subroutine reference that can be run to
     # start the process
   }

 package MyIterator::Visitor;
   use Moose;
   extends 'Utukku::Engine::Iterator::Visitor';

   sub start    { }
   sub value    { }
   sub next     { }
   sub at_end   { }
   sub past_end { }

=head1 DESCRIPTION

All iterators in the Utukku engine are derived from the C<Iterator> and
C<Iterator::Visitor> classes.
