#!perl -T

use Test::More tests => 2;

use Bamboo;

BEGIN {
  use_ok( 'Bamboo::Server::Connection' );
  use_ok( 'Bamboo::Server' );
}

diag( "Testing Bamboo::Server" );
