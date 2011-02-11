package Utukku::Engine::Parser::CurrentContext;
  use Moose;

  use Utukku::Engine::ConstantIterator;

  sub run {
    my($self, $context, $av) = @_;

    Utukku::Engine::ConstantIterator -> new(
      values => [ $context -> node ]
    );
  }

1;
