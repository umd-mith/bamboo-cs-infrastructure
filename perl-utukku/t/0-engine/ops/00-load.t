#!perl -T

use Test::More tests => 10;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Engine::Iterator' );
  use_ok( 'Utukku::Engine::ConstantIterator' );
  use_ok( 'Utukku::Engine::RangeIterator' );
  use_ok( 'Utukku::Engine::ConstantRangeIterator' );
  use_ok( 'Utukku::Engine::NullIterator' );
  use_ok( 'Utukku::Engine::UnionIterator' );
  use_ok( 'Utukku::Engine::Block' );
  use_ok( 'Utukku::Engine::Types' );
  use_ok( 'Utukku::Engine::Type' );
  use_ok( 'Utukku::Engine::Parser::BinExpr' );
}

diag( "Testing Utukku::Engine Operations" );
