#!perl -T

use Test::More tests => 15;
use Data::Dumper;

use Utukku::Engine::Block;
use Utukku::Engine::Parser::Literal;
use Utukku::Engine::Parser::BinExpr;

can_ok('Utukku::Engine::Block', qw( new ));

can_ok('Utukku::Engine::Block', qw( statements ensures catches ));

can_ok('Utukku::Engine::Block', qw( run ));

my $block = new_ok( 'Utukku::Engine::Block' );

ok($block -> noop, "New block is a no-op");

$block -> add_statement(
  Utukku::Engine::Parser::AddExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 2 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 3 )
  )
);

ok(!$block -> noop, "Block with added statement is not a no-op");

my $it = $block -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

my $vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, 5);
ok($vis -> at_end);

$block -> add_statement(
  Utukku::Engine::Parser::AddExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 1 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 2 )
  )
);

is(scalar(@{$block -> statements}), 2, "There are two statements in the block");

$it = $block -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, 3);
ok($vis -> at_end);
