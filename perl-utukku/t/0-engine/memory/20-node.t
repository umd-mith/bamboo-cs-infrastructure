#!perl -T

use Test::More tests => 6;

use Utukku::Engine::Memory::Node;

can_ok('Utukku::Engine::Memory::Node', qw( new ));

can_ok('Utukku::Engine::Memory::Node', qw( axis parent children ));

my $node = new_ok( 'Utukku::Engine::Memory::Node', [
  value => 'foo',
  name  => 'bar',
]);

is( $node -> name, 'bar' );
is( $node -> value, 'foo' );

my @stype = (
      namespace => 'http://dh.tamu.edu/ns/fabulator/1.0#',
      name      => 'string'
);

is( $node -> type, Utukku::Engine::Type->new(@stype) );



1;
