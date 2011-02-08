package Bamboo::Engine::Expression;
  use Moose;

  use Bamboo::Engine::NullIterator;

  sub run {
    return Bamboo::Engine::NullIterator -> new;
  }

  sub invert {
    my($self, $context, $av, $callbacks) = @_;

    $self -> run( $context, $av ) -> invert($callbacks);
  }

  sub simplfy { $_[0] }

1;
