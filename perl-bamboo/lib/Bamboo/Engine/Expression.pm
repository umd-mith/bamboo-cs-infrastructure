package Bamboo::Engine::Expression;
  use Moose;

  use Bamboo::Engine::NullIterator;

  sub run {
    return Bamboo::Engine::NullIterator -> new;
  }

  sub simplfy { $_[0] }

1;
