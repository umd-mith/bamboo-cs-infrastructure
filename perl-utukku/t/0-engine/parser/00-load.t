#!perl -T

use Test::More tests => 1;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Engine::Parser' );
}

diag( "Testing Utukku::Engine::Parser" );
