package Bamboo::Engine::Parser::RangeExpr;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::RangeIterator;

  use Bamboo::Engine::Types qw( Expression );


  has begin => ( isa => Expression, is => 'rw' );
  has end   => ( isa => Expression, is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    return Bamboo::Engine::RangeIterator -> new(
      begin => $self -> begin -> run($context, $av),
      end   => $self -> end   -> run($context, $av),
    );
  }

1;
