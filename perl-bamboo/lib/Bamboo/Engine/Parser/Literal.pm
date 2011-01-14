package Bamboo::Engine::Parser::Literal;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::ConstantIterator;

  has 'value' => ( is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    #we want to produce an iterator that returns each one in turn

    return Bamboo::Engine::ConstantIterator -> new(
      values => [ $self -> value ]
    );
  }

1;
