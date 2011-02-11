#!perl -T

use Test::More tests => 1;

BEGIN {
  use_ok( 'Utukku' );
}

diag( "Testing Utukku $Utukku::VERSION, Perl $], $^X" );
