package Bamboo::Engine::Parser::UnionExpr;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::UnionIterator;

  use MooseX::Types::Moose qw(ArrayRef);

  has exprs => (is => 'rw', isa => ArrayRef);

  sub run {
    my($self, $context, $av) = @_;

    return Bamboo::Engine::UnionIterator -> new(
      iterators => [
        map { $_ -> run($context, $av) } grep { ref $_ } @{$self -> exprs}
      ]
    );
  }

1;
