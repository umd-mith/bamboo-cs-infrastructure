package Bamboo::Engine::Parser::AndExpr;
  use Moose;
  extends 'Bamboo::Engine::Expression';

  use Bamboo::Engine::Types qw( Expression );
  use MooseX::Types::Moose qw( ArrayRef );

  has 'expr'  => ( is => 'rw', isa => Expression );
  has 'tests' => ( is => 'rw', isa => ArrayRef, default => sub { [ ] } );

  sub run {
    my($self, $context, $av) = @_;

  }

  sub add_and {
    my($self, $expr) = @_;
    push @{$self -> tests}, [ 0, $expr ];
  }

  sub add_except {
    my($self, $expr) = @_;
    push @{$self -> tests}, [ 1, $expr ];
  }

  sub simplify {
    my($self) = @_;

    if( @{$self -> tests} == 0 ) {
      return $self -> expr;
    }
    return $self;
  }

1;

