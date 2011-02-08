#!perl -T

use Test::More tests => 4;
use Data::Dumper;

use Bamboo::Engine::Parser;

can_ok('Bamboo::Engine::Parser', qw( new ));

can_ok('Bamboo::Engine::Parser', qw( _Lexer _Error parse ));

my $parser = new_ok( 'Bamboo::Engine::Parser' );

my $context = Bamboo::Engine::Context -> new;

eval { $parser -> parse($context, '(: (: :)'); };

like( $@, qr/Unbalanced comment delimiters/ );
