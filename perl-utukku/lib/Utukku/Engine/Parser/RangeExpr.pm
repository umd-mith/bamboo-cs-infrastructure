package Utukku::Engine::Parser::RangeExpr;
  use Moose;
  extends 'Utukku::Engine::Expression';

  use Utukku::Engine::RangeIterator;

  use Utukku::Engine::Types qw( Expression );


  has begin => ( isa => Expression, is => 'rw' );
  has end   => ( isa => Expression, is => 'rw' );
  has incr  => ( isa => Expression, is => 'rw', predicate => 'has_incr' );

  sub run {
    my($self, $context, $av) = @_;

    if( $self -> has_incr ) {
      return Utukku::Engine::RangeIterator -> new(
        begin => $self -> begin -> run($context, $av),
        end   => $self -> end   -> run($context, $av),
        incr  => $self -> incr  -> run($context, $av),
      );
    }
    else {
      return Utukku::Engine::RangeIterator -> new(
        begin => $self -> begin -> run($context, $av),
        end   => $self -> end   -> run($context, $av),
      );
    }
  }

1;
