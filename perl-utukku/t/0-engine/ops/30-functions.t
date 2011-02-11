#! perl -w

use Test::More tests => 2;

use Utukku::Engine::Parser::FunctionCall;
use Utukku::Engine::Context;
use Utukku::Engine::Parser::Literal;

can_ok('Utukku::Engine::Parser::FunctionCall', qw( new run ));

my $context = Utukku::Engine::Context -> new;

my $fc = new_ok( 'Utukku::Engine::Parser::FunctionCall', [
  name => 'f:count',
  args => [ ],
] );
