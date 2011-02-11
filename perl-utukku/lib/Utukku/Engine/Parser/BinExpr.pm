package Utukku::Engine::Parser::BinExpr;
  use Moose;
  extends 'Utukku::Engine::Expression';

  use Utukku::Engine::SetIterator;

  use Utukku::Engine::Types qw(Expression);

  has 'left' => ( isa => Expression, is => 'rw' );
  has 'right' => ( isa => Expression, is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    #we want to produce an iterator that returns each one in turn

    return Utukku::Engine::SetIterator -> new(
      sets => [ 
        $self -> left -> run($context, $av), 
        $self -> right -> run($context, $av) 
      ],
      combinator => sub { $self -> combine(@_) },
    );
  }

  sub combine {
    my($self, $a, $b) = @_;

    # do operator overloading look up here

    return $self -> calculate($a, $b);
  }

package Utukku::Engine::Parser::AddExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a + $b;
  }

package Utukku::Engine::Parser::SubExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a - $b;
  }

package Utukku::Engine::Parser::MpyExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a * $b;
  }

package Utukku::Engine::Parser::DivExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a / $b;
  }

package Utukku::Engine::Parser::ModExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a % $b;
  }

package Utukku::Engine::Parser::LtExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a < $b;
  }

package Utukku::Engine::Parser::LteExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a <= $b;
  }

package Utukku::Engine::Parser::EqExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a eq $b;
  }

package Utukku::Engine::Parser::NeqExpr;
  use Moose;

  extends 'Utukku::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a ne $b;
  }

1;
