package Utukku::Engine::Expression;
  use Moose;

  use Utukku::Engine::NullIterator;

  sub run {
    return Utukku::Engine::NullIterator -> new;
  }

  sub invert {
    my($self, $context, $av, $callbacks) = @_;

    $self -> run( $context, $av ) -> invert($callbacks);
  }

  sub simplfy { $_[0] }

1;
