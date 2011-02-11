#!perl -T

use Test::More tests => 4;
use Data::Dumper;

use Utukku::Engine::Parser;

can_ok('Utukku::Engine::Parser', qw( new ));

can_ok('Utukku::Engine::Parser', qw( _Lexer _Error parse ));

my $parser = new_ok( 'Utukku::Engine::Parser' );

my $context = Utukku::Engine::Context -> new;

eval { $parser -> parse($context, '(: (: :)'); };

like( $@, qr/Unbalanced comment delimiters/ );
