#!perl -T

use Test::More tests => 2;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Server::Connection' );
  use_ok( 'Utukku::Server' );
}

diag( "Testing Utukku::Server" );
