#!perl -T

use Test::More tests => 2;

use Utukku;

BEGIN {
  use_ok( 'Utukku::Client::Connection' );
  use_ok( 'Utukku::Client' );
}

diag( "Testing Utukku::Client" );
