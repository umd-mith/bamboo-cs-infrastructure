package Utukku::Engine::Expression;
  use Moose;
  use Carp;

  use Utukku::Engine::NullIterator;

  sub run {
    return Utukku::Engine::NullIterator -> new;
  }

  sub build_async {
    my($self, $context, $av, $callbacks) = @_;

    $self -> run( $context, $av ) -> build_async($callbacks);
  }

  sub async {
    my($self, $context, $av, $callbacks) = @_;

    $_->() for $self -> build_async($context, $av, $callbacks);
  }

  sub invert {
    my $self = shift;

    carp "Deprecated use of invert";

    $self -> build_async(@_);
  }

  sub simplfy { $_[0] }

1;
