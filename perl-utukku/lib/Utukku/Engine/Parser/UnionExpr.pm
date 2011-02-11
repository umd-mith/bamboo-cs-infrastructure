package Utukku::Engine::Parser::UnionExpr;
  use Moose;
  extends 'Utukku::Engine::Expression';

  use Utukku::Engine::UnionIterator;

  use MooseX::Types::Moose qw(ArrayRef);

  has exprs => (is => 'rw', isa => ArrayRef);

  sub run {
    my($self, $context, $av) = @_;

    return Utukku::Engine::UnionIterator -> new(
      iterators => [
        map { $_ -> run($context, $av) } grep { ref $_ } @{$self -> exprs}
      ]
    );
  }

1;
