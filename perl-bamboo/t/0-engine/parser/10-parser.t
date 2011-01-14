#!perl -T

use Test::More tests => 4;
use Data::Dumper;

use Bamboo::Engine::Parser;

can_ok('Bamboo::Engine::Parser', qw( new ));

can_ok('Bamboo::Engine::Parser', qw( _Lexer _Error parse ));

my $parser = new_ok( 'Bamboo::Engine::Parser' );

eval { $parser -> parse('(: (: :)'); };

like( $@, qr/Unbalanced comment delimiters/ );

#printf STDERR "\n\n". Data::Dumper -> Dump([$parser -> parse('; ; ;', 1)]). "\n\n";
#printf STDERR "\n\n". Data::Dumper -> Dump([$parser -> parse('1 + 1; 2+2', 1)]). "\n\n";
