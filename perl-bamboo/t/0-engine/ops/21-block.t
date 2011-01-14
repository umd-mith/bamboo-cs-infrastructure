#!perl -T

use Test::More tests => 15;
use Data::Dumper;

use Bamboo::Engine::Block;
use Bamboo::Engine::Parser::Literal;
use Bamboo::Engine::Parser::BinExpr;

can_ok('Bamboo::Engine::Block', qw( new ));

can_ok('Bamboo::Engine::Block', qw( statements ensures catches ));

can_ok('Bamboo::Engine::Block', qw( run ));

my $block = new_ok( 'Bamboo::Engine::Block' );

ok($block -> noop, "New block is a no-op");

$block -> add_statement(
  Bamboo::Engine::Parser::AddExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 3 )
  )
);

ok(!$block -> noop, "Block with added statement is not a no-op");

my $it = $block -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

my $vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, 5);
ok($vis -> at_end);

$block -> add_statement(
  Bamboo::Engine::Parser::AddExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 1 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 2 )
  )
);

is(scalar(@{$block -> statements}), 2, "There are two statements in the block");

$it = $block -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, 3);
ok($vis -> at_end);
