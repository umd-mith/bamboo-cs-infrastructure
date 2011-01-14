#!perl -T

use Test::More tests => 1;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Engine::Memory::Node' );
}

diag( "Testing Bamboo::Engine::Memory" );
