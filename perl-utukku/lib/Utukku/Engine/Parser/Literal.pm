package Utukku::Engine::Parser::Literal;
  use Moose;
  extends 'Utukku::Engine::Expression';

  use Utukku::Engine::ConstantIterator;

  has 'value' => ( is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    #we want to produce an iterator that returns each one in turn

    return Utukku::Engine::ConstantIterator -> new(
      values => [ $self -> value ]
    );
  }

1;
