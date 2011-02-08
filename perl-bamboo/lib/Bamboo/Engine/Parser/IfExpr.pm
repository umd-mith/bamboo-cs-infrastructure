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

  sub invert {
    my($self, $context, $av, $callbacks) = @_;

    my $then_run;
    $self -> test -> run($context, $av) -> invert({
      'done' => sub {
        if(!$then_run && $self -> has_else) {
          $_ -> () for $self -> else -> run($context, $av) -> invert($callbacks);
        }
        else {
          $callbacks -> {done} -> ();
        }
      },
      'next' => sub {
        if(!$then_run && !!$_[0]) {
          $then_run = 1;
          $_ -> () for $self -> then -> run($context, $av) -> invert($callbacks);
        }
      }
    });
  }

1;
