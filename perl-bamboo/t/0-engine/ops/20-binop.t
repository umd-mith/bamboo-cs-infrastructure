#!perl -T

use Test::More tests => 16;
use Data::Dumper;

use Bamboo::Engine::Parser::BinExpr;
use Bamboo::Engine::Parser::Literal;


my $expr = Bamboo::Engine::Parser::AddExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 3 )
  );

my $it = $expr -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

my $vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, 5);
ok($vis -> at_end);

$expr = Bamboo::Engine::Parser::SubExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, -1);
ok($vis -> at_end);

$expr = Bamboo::Engine::Parser::MpyExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, 6);
ok($vis -> at_end);

$expr = Bamboo::Engine::Parser::ModExpr -> new(
    left => Bamboo::Engine::Parser::Literal -> new( value => 5 ),
    right => Bamboo::Engine::Parser::Literal -> new( value => 3 )
  );

$it = $expr -> run();

isa_ok($it, 'Bamboo::Engine::Iterator');

$vis = $it -> start;

isa_ok($vis, 'Bamboo::Engine::Iterator::Visitor');

is($vis -> next, 2);
ok($vis -> at_end);

