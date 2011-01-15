#! perl -w

use Test::More tests => 6;

use Bamboo::Engine::Parser::IfExpr;
use Bamboo::Engine::Parser::Literal;

can_ok('Bamboo::Engine::Parser::IfExpr', qw( new run ));

my $if = new_ok( 'Bamboo::Engine::Parser::IfExpr', [
  'test' => Bamboo::Engine::Parser::Literal -> new( value => 1 ),
  'then' => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
  'else' => Bamboo::Engine::Parser::Literal -> new( value => 3 ),
] );

my $iterator = $if -> run();

isa_ok( $iterator, 'Bamboo::Engine::Iterator' );

ok( $iterator -> all( sub { $_[0] == 2 } ) );

$if = Bamboo::Engine::Parser::IfExpr -> new(
  'test' => Bamboo::Engine::Parser::Literal -> new( value => 0 ),
  'then' => Bamboo::Engine::Parser::Literal -> new( value => 2 ),
  'else' => Bamboo::Engine::Parser::Literal -> new( value => 3 ),
);

$iterator = $if -> run();

isa_ok( $iterator, 'Bamboo::Engine::Iterator' );

ok( $iterator -> all( sub { $_[0] == 3 } ) );
