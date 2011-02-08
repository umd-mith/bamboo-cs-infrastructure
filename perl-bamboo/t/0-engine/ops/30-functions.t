#! perl -w

use Test::More tests => 2;

use Bamboo::Engine::Parser::FunctionCall;
use Bamboo::Engine::Context;
use Bamboo::Engine::Parser::Literal;

can_ok('Bamboo::Engine::Parser::FunctionCall', qw( new run ));

my $context = Bamboo::Engine::Context -> new;

my $fc = new_ok( 'Bamboo::Engine::Parser::FunctionCall', [
  name => 'f:count',
  args => [ ],
] );
