#!perl -T

use Test::More tests => 39;
use Data::Dumper;

use Bamboo::Engine::Parser::RangeExpr;
use Bamboo::Engine::Parser::Literal;
use Bamboo::Engine::Parser::BinExpr;

my $range = Bamboo::Engine::Parser::RangeExpr -> new(
    begin => Bamboo::Engine::Parser::Literal -> new( value => 1 ),
    end   => Bamboo::Engine::Parser::Literal -> new( value => 5 ),
);

my $vals = $range -> run -> start;

is($vals -> next, 1);
is($vals -> next, 2);
is($vals -> next, 3);
is($vals -> next, 4);
is($vals -> next, 5);
ok($vals -> at_end);

my $expr = Bamboo::Engine::Parser::AddExpr -> new(
  left => Bamboo::Engine::Parser::RangeExpr -> new(
    begin => Bamboo::Engine::Parser::Literal -> new( value => 1 ),
    end   => Bamboo::Engine::Parser::Literal -> new( value => 5 ),
  ),
  right => Bamboo::Engine::Parser::RangeExpr -> new(
    begin => Bamboo::Engine::Parser::Literal -> new( value => 1 ),
    end   => Bamboo::Engine::Parser::Literal -> new( value => 5 ),
  ),
);

$vals = $expr -> run() -> start;

is($vals -> next, 2);
is($vals -> next, 3);
is($vals -> next, 4);
is($vals -> next, 5);
is($vals -> next, 6);

ok(!$vals -> at_end);

is($vals -> next, 3);
is($vals -> next, 4);
is($vals -> next, 5);
is($vals -> next, 6);
is($vals -> next, 7);

ok(!$vals -> at_end);

is($vals -> next, 4);
is($vals -> next, 5);
is($vals -> next, 6);
is($vals -> next, 7);
is($vals -> next, 8);

ok(!$vals -> at_end);

is($vals -> next, 5);
is($vals -> next, 6);
is($vals -> next, 7);
is($vals -> next, 8);
is($vals -> next, 9);

ok(!$vals -> at_end);

is($vals -> next, 6);
is($vals -> next, 7);
is($vals -> next, 8);
is($vals -> next, 9);
is($vals -> next, 10);

ok($vals -> at_end);
ok(!$vals -> past_end);

is($vals -> next, undef);
ok($vals -> past_end);
