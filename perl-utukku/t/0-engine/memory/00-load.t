#!perl -T

use Test::More tests => 1;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Engine::Memory::Node' );
}

diag( "Testing Utukku::Engine::Memory" );
