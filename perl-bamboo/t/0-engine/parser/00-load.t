#!perl -T

use Test::More tests => 1;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Engine::Parser' );
}

diag( "Testing Bamboo::Engine::Parser" );
