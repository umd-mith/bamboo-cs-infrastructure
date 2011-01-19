#!perl -T

use Test::More tests => 10;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Engine::Iterator' );
  use_ok( 'Bamboo::Engine::ConstantIterator' );
  use_ok( 'Bamboo::Engine::RangeIterator' );
  use_ok( 'Bamboo::Engine::ConstantRangeIterator' );
  use_ok( 'Bamboo::Engine::NullIterator' );
  use_ok( 'Bamboo::Engine::UnionIterator' );
  use_ok( 'Bamboo::Engine::Block' );
  use_ok( 'Bamboo::Engine::Types' );
  use_ok( 'Bamboo::Engine::Type' );
  use_ok( 'Bamboo::Engine::Parser::BinExpr' );
}

diag( "Testing Bamboo::Engine Operations" );
