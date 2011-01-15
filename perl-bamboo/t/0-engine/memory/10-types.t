#!perl -T

use Test::More tests => 7;

use Bamboo::Engine::Type;

can_ok('Bamboo::Engine::Type', qw( new ));

my @stype = (
      namespace => 'http://dh.tamu.edu/ns/fabulator/1.0#',
      name      => 'string'
);

my $t1 = new_ok( 'Bamboo::Engine::Type', [ @stype ] );
my $t2 = new_ok( 'Bamboo::Engine::Type', [ @stype ] );

is( $t1, $t2, "Types are singular" );

1;
