#! perl -w

use Test::More tests => 6;

use Utukku::Engine::Parser::IfExpr;
use Utukku::Engine::Parser::Literal;

can_ok('Utukku::Engine::Parser::IfExpr', qw( new run ));

my $if = new_ok( 'Utukku::Engine::Parser::IfExpr', [
  'test' => Utukku::Engine::Parser::Literal -> new( value => 1 ),
  'then' => Utukku::Engine::Parser::Literal -> new( value => 2 ),
  'else' => Utukku::Engine::Parser::Literal -> new( value => 3 ),
] );

my $iterator = $if -> run();

isa_ok( $iterator, 'Utukku::Engine::Iterator' );

ok( $iterator -> all( sub { $_[0] == 2 } ) );

$if = Utukku::Engine::Parser::IfExpr -> new(
  'test' => Utukku::Engine::Parser::Literal -> new( value => 0 ),
  'then' => Utukku::Engine::Parser::Literal -> new( value => 2 ),
  'else' => Utukku::Engine::Parser::Literal -> new( value => 3 ),
);

$iterator = $if -> run();

isa_ok( $iterator, 'Utukku::Engine::Iterator' );

ok( $iterator -> all( sub { $_[0] == 3 } ) );
