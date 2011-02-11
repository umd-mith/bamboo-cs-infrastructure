package Utukku::Engine::Parser::PathExpr;
  use Moose;

  extends 'Utukku::Engine::Expression';

  has primary => ( is => 'rw' );

  has predicates => ( is => 'rw' );

  has segment => ( is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    Utukku::Engine::MapIterator -> new(
      iterator => Utukku::Engine::FilterIterator -> new(
        iterator => $self -> primary -> run($context, $av),
        filter   => sub { $self -> predicates -> filter($_[0]) },
      ),
      mapping => sub { $self -> segment -> run($_[0]) }
    );
  }
1;
