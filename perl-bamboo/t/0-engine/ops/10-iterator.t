#!perl -T

use Test::More tests => 134;
use Data::Dumper;

use Bamboo::Engine::SetIterator;
use Bamboo::Engine::ConstantIterator;
use Bamboo::Engine::RangeIterator;
use Bamboo::Engine::UnionIterator;
use Bamboo::Engine::Parser::Literal;
use Bamboo::Engine::NullIterator;
use Bamboo::Engine::FilterIterator;

can_ok('Bamboo::Engine::SetIterator', qw( new ));
can_ok('Bamboo::Engine::ConstantIterator', qw( new ));
can_ok('Bamboo::Engine::RangeIterator', qw( new ));
can_ok('Bamboo::Engine::ConstantRangeIterator', qw( new ));
can_ok('Bamboo::Engine::UnionIterator', qw( new ));
can_ok('Bamboo::Engine::NullIterator', qw( new ));
can_ok('Bamboo::Engine::FilterIterator', qw( new ));

can_ok('Bamboo::Engine::SetIterator', qw( start ));
can_ok('Bamboo::Engine::ConstantIterator', qw( start ));
can_ok('Bamboo::Engine::UnionIterator', qw( start ));
can_ok('Bamboo::Engine::NullIterator', qw( start ));
can_ok('Bamboo::Engine::FilterIterator', qw( start ));

can_ok('Bamboo::Engine::SetIterator::Visitor', qw( next at_end position ));
can_ok('Bamboo::Engine::ConstantIterator::Visitor', qw( next at_end position ));
can_ok('Bamboo::Engine::UnionIterator::Visitor', qw( next at_end position ));
can_ok('Bamboo::Engine::NullIterator::Visitor', qw( next at_end position ));
can_ok('Bamboo::Engine::FilterIterator::Visitor', qw( next at_end position ));

my $iterator = new_ok( 'Bamboo::Engine::ConstantIterator', [
  values => [ qw(a b c) ] 
] );

my $visitor = $iterator -> start;

ok($visitor);

is($visitor -> position, 0, "Initial position should be zero");

is($visitor -> next, 'a');
is($visitor -> position, 1);
ok(!$visitor -> at_end);
is($visitor -> next, 'b');
is($visitor -> position, 2);
ok(!$visitor -> at_end);
is($visitor -> next, 'c');
is($visitor -> position, 3);
ok($visitor -> at_end);
ok(!defined($visitor -> next));
is($visitor -> position, 3);
ok($visitor -> at_end);


my $literal = new_ok( 'Bamboo::Engine::Parser::Literal', [
  value => 'a' 
] );

ok($literal);

my $dummy_context = undef;

my $lit_it = $literal -> run($dummy_context);

ok($lit_it);

my $lit_it_vis = $lit_it -> start;

is($lit_it_vis -> position, 0);
is($lit_it_vis -> next, 'a');
is($lit_it_vis -> position, 1);
ok($lit_it_vis -> at_end);

my $combo = new_ok( 'Bamboo::Engine::SetIterator', [
  sets => [ Bamboo::Engine::ConstantIterator -> new( values => [ 1, 2, 3 ] ),
            Bamboo::Engine::ConstantIterator -> new( values => [ 2, 4, 6 ] )
          ],
  combinator => sub { my($a, $b) = @_; return $a * $b }
] );

ok($combo);

my $combos = $combo -> start;

ok($combos);
is($combos -> position, 0);
is($combos -> next, 2);
is($combos -> position, 1);
is($combos -> next, 4);
is($combos -> position, 2);
is($combos -> next, 6);
is($combos -> position, 3);
is($combos -> next, 4);
is($combos -> position, 4);
is($combos -> next, 8);
is($combos -> position, 5);
is($combos -> next, 12);
is($combos -> position, 6);
is($combos -> next, 6);
is($combos -> position, 7);
is($combos -> next, 12);
is($combos -> position, 8);
is($combos -> next, 18);
is($combos -> position, 9);
ok($combos -> at_end);
ok(!$combos -> past_end);
is($combos -> next, undef);
ok($combos -> past_end);

my $range_it = Bamboo::Engine::ConstantRangeIterator -> new(
  begin => 10,
  end   => 14
);

my $rv = $range_it -> start;

is($rv -> next, 10);
is($rv -> next, 11);
is($rv -> next, 12);
is($rv -> next, 13);
is($rv -> next, 14);
is($rv -> position, 5);
ok($rv -> at_end);
ok(!$rv -> past_end);

$range_it = Bamboo::Engine::ConstantRangeIterator -> new(
  begin => 14,
  end   => 10
);

$rv = $range_it -> start;

is($rv -> next, 14);
is($rv -> next, 13);
is($rv -> next, 12);
is($rv -> next, 11);
is($rv -> next, 10);
is($rv -> position, 5);
ok($rv -> at_end);
ok(!$rv -> past_end);

$range_it = Bamboo::Engine::RangeIterator -> new(
  begin => Bamboo::Engine::ConstantRangeIterator -> new(
    begin => 1,
    end   => 3
  ),
  end => Bamboo::Engine::ConstantRangeIterator -> new(
    begin => 4,
    end   => 5
  ),
);

$rv = $range_it -> start;

is($rv -> next, 1);
is($rv -> next, 2);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 2);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 1);
is($rv -> next, 2);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 5);
is($rv -> next, 2);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 5);
is($rv -> next, 3);
is($rv -> next, 4);
is($rv -> next, 5);
is($rv -> position, 21);
ok($rv -> at_end);

my $union_it = Bamboo::Engine::UnionIterator -> new(
  iterators => [
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1,
      end => 3,
    ),
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 7,
      end => 9,
    ),
  ]
);

my $uv = $union_it -> start;

is($uv -> next, 1);
is($uv -> next, 2);
is($uv -> next, 3);
is($uv -> next, 7);
is($uv -> next, 8);
is($uv -> next, 9);
is($uv -> position, 6);
ok($uv -> at_end);

my $null_it = new_ok( 'Bamboo::Engine::NullIterator' );

my $null_visitor = $null_it -> start;

ok($null_visitor);

is($null_visitor -> position, 0);
ok($null_visitor -> at_end);
ok($null_visitor -> past_end);

my $filter_it = new_ok( 'Bamboo::Engine::FilterIterator', [
  iterator => Bamboo::Engine::ConstantRangeIterator -> new(
                begin => 1, end => 100
              ),
  filter => sub { $_[0] % 11 == 0 }
]);

my $filter_visitor = $filter_it -> start;

ok($filter_visitor);

is($filter_visitor -> position, 0);
is($filter_visitor -> next, 11);
is($filter_visitor -> position, 1);
is($filter_visitor -> next, 22);
is($filter_visitor -> position, 2);
is($filter_visitor -> next, 33);
is($filter_visitor -> position, 3);
is($filter_visitor -> next, 44);
is($filter_visitor -> next, 55);
is($filter_visitor -> next, 66);
is($filter_visitor -> next, 77);
is($filter_visitor -> next, 88);
is($filter_visitor -> next, 99);
is($filter_visitor -> position, 9);
ok($filter_visitor -> at_end);
