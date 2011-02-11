use Test::More tests => 3 * 8;
use Data::Dumper;

use Utukku::Engine::Parser;

# 3 tests for each time this is invoked
sub test_expr {
  my($expr, $res, $desc) = @_;

  my $parser = Utukku::Engine::Parser -> new;

  my $context = Utukku::Engine::Context -> new;

  my $it = eval { $parser -> parse($context, $expr) -> run($context); };

  ok(!$@);

  isa_ok( $it, 'Utukku::Engine::Iterator' );

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
