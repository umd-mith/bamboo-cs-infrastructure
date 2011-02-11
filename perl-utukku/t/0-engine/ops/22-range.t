#!perl -T

use Test::More tests => 39;
use Data::Dumper;

use Utukku::Engine::Parser::RangeExpr;
use Utukku::Engine::Parser::Literal;
use Utukku::Engine::Parser::BinExpr;

my $range = Utukku::Engine::Parser::RangeExpr -> new(
    begin => Utukku::Engine::Parser::Literal -> new( value => 1 ),
    end   => Utukku::Engine::Parser::Literal -> new( value => 5 ),
);

my $vals = $range -> run -> start;

is($vals -> next, 1);
is($vals -> next, 2);
is($vals -> next, 3);
is($vals -> next, 4);
is($vals -> next, 5);
ok($vals -> at_end);

my $expr = Utukku::Engine::Parser::AddExpr -> new(
  left => Utukku::Engine::Parser::RangeExpr -> new(
    begin => Utukku::Engine::Parser::Literal -> new( value => 1 ),
    end   => Utukku::Engine::Parser::Literal -> new( value => 5 ),
  ),
  right => Utukku::Engine::Parser::RangeExpr -> new(
    begin => Utukku::Engine::Parser::Literal -> new( value => 1 ),
    end   => Utukku::Engine::Parser::Literal -> new( value => 5 ),
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
