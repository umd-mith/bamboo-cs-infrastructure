#!perl -T

use Test::More tests => 1;

BEGIN {
  use_ok( 'Bamboo' );
}

diag( "Testing Bamboo $Bamboo::VERSION, Perl $], $^X" );
