#!perl -T

use Test::More tests => 16;
use Data::Dumper;

use Utukku::Engine::Parser::BinExpr;
use Utukku::Engine::Parser::Literal;


my $expr = Utukku::Engine::Parser::AddExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 2 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 3 )
  );

my $it = $expr -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

my $vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, 5);
ok($vis -> at_end);

$expr = Utukku::Engine::Parser::SubExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 2 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, -1);
ok($vis -> at_end);

$expr = Utukku::Engine::Parser::MpyExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 2 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, 6);
ok($vis -> at_end);

$expr = Utukku::Engine::Parser::ModExpr -> new(
    left => Utukku::Engine::Parser::Literal -> new( value => 5 ),
    right => Utukku::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Utukku::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Utukku::Engine::Iterator::Visitor');

is($vis -> next, 2);
ok($vis -> at_end);

