package Utukku::Engine::Parser::ParentContext;
  use Moose;

  use Utukku::Engine::Types qw( Context Node );

  use Utukku::Engine::MapIterator;

  sub run {
    my($self, $context, $av) = @_;

    Utukku::Engine::ConstantIterator -> new(
      values => [ $context -> node -> parent ]
    );
  }

1;
