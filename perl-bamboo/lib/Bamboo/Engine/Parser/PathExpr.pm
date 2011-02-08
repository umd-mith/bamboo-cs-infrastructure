package Bamboo::Engine::Parser::PathExpr;
  use Moose;

  extends 'Bamboo::Engine::Expression';

  has primary => ( is => 'rw' );

  has predicates => ( is => 'rw' );

  has segment => ( is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    Bamboo::Engine::MapIterator -> new(
      iterator => Bamboo::Engine::FilterIterator -> new(
        iterator => $self -> primary -> run($context, $av),
        filter   => sub { $self -> predicates -> filter($_[0]) },
      ),
      mapping => sub { $self -> segment -> run($_[0]) }
    );
  }
1;
