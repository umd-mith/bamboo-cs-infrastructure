#!perl -T

use Test::More tests => 2;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Agent::Connection' );
  use_ok( 'Utukku::Agent' );
}

diag( "Testing Utukku::Agent" );
