#!perl -T

use Test::More tests => 2;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Client::Connection' );
  use_ok( 'Bamboo::Client' );
}

diag( "Testing Bamboo::Client" );
