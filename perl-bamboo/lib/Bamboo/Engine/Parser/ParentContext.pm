package Bamboo::Engine::Parser::ParentContext;
  use Moose;

  use Bamboo::Engine::Types qw( Context Node );

  use Bamboo::Engine::MapIterator;

  sub run {
    my($self, $context, $av) = @_;

    Bamboo::Engine::ConstantIterator -> new(
      values => [ $context -> node -> parent ]
    );
  }

1;
