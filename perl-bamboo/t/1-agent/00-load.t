#!perl -T

use Test::More tests => 2;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Agent::Connection' );
  use_ok( 'Bamboo::Agent' );
}

diag( "Testing Bamboo::Agent" );
