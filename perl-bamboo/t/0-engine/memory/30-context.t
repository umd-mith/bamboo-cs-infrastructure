#!perl -T

use Test::More tests => 5;

use Bamboo::Engine::Context;

can_ok('Bamboo::Engine::Context', qw( new ));

can_ok('Bamboo::Engine::Context', qw( with_node ));

my $node1 = Bamboo::Engine::Memory::Node -> new(
  value => 'foo',
  name => 'bar'
);

my $node2 = Bamboo::Engine::Memory::Node -> new(
  value => 'f00',
  name => 'baz'
);

my $context = new_ok( 'Bamboo::Engine::Context', [
  node => $node1
] );

is( $context -> node -> name, 'bar' );

$context -> with_node( $node2, sub {
  my($context) = @_;

  is( $context -> node -> name, 'baz' );
} );
