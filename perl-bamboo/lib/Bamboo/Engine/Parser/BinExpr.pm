package Bamboo::Engine::Parser::BinExpr;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::SetIterator;

  use Bamboo::Engine::Types qw(Expression);

  has 'left' => ( isa => Expression, is => 'rw' );
  has 'right' => ( isa => Expression, is => 'rw' );

  sub run {
    my($self, $context, $av) = @_;

    #we want to produce an iterator that returns each one in turn

    return Bamboo::Engine::SetIterator -> new(
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

package Bamboo::Engine::Parser::AddExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a + $b;
  }

package Bamboo::Engine::Parser::SubExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a - $b;
  }

package Bamboo::Engine::Parser::MpyExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a * $b;
  }

package Bamboo::Engine::Parser::DivExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a / $b;
  }

package Bamboo::Engine::Parser::ModExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a % $b;
  }

package Bamboo::Engine::Parser::LtExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a < $b;
  }

package Bamboo::Engine::Parser::LteExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a <= $b;
  }

package Bamboo::Engine::Parser::EqExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a eq $b;
  }

package Bamboo::Engine::Parser::NeqExpr;
  use Moose;

  extends 'Bamboo::Engine::Parser::BinExpr';

  sub calculate {
    my($self, $a, $b) = @_;

    return $a ne $b;
  }

1;
