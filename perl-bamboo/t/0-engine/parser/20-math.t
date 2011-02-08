use Test::More tests => 3 * 8;
use Data::Dumper;

use Bamboo::Engine::Parser;

# 3 tests for each time this is invoked
sub test_expr {
  my($expr, $res, $desc) = @_;

  my $parser = Bamboo::Engine::Parser -> new;

  my $context = Bamboo::Engine::Context -> new;

  my $it = eval { $parser -> parse($context, $expr) -> run($context); };

  ok(!$@);

  isa_ok( $it, 'Bamboo::Engine::Iterator' );

  if( $it ) {
    my $v = $it -> start;

    my @vr;

    while(! $v -> at_end ) {
      push @vr, $v -> next;
    }

    is_deeply(\@vr, $res, $desc || $expr);
  }
  else {
    ok(0);
  }
}

test_expr( '1 + 2', [ 3 ] );
test_expr( '3 - 1', [ 2 ] );
test_expr( '3 * 2', [ 6 ] );
test_expr( '1 + 2 * 3 + 4', [ 11 ] );
test_expr( '29 mod 4', [ 1 ] );
test_expr( '123 div 3', [ 41 ] );
test_expr( '(3 * 2) | (4 * 3)', [ 6, 12 ] );
test_expr( '3 * (2 | 4) * 3', [ 18, 36 ] );
