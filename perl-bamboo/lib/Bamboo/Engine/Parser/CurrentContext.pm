package Bamboo::Engine::Parser::CurrentContext;
  use Moose;

  use Bamboo::Engine::ConstantIterator;

  sub run {
    my($self, $context, $av) = @_;

    Bamboo::Engine::ConstantIterator -> new(
      values => [ $context -> node ]
    );
  }

1;
