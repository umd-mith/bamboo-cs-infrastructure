package Bamboo::Engine::Parser::IfExpr;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::NullIterator;

  use Bamboo::Engine::Types qw( Expression );

  has 'test' => ( is => 'rw', isa => Expression );
  has 'then' => ( is => 'rw', isa => Expression );
  has 'else' => ( is => 'rw', isa => Expression, predicate => 'has_else' );

  sub run {
    my($self, $context, $av) = @_;

    my $res = $self -> test -> run($context, $av);
# TODO: convert values to boolean first
    if( $res -> any( sub { !!$_[0] } ) ) {
      return $self -> then -> run($context, $av);
    }
    elsif( $self -> has_else ) {
      return $self -> else -> run($context, $av);
    }
    else {
      return Bamboo::Engine::NullIterator -> new;
    }
  }

1;
