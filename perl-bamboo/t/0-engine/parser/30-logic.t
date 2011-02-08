use Test::More tests => 3 * 6;
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

test_expr( 'if( 1 < 2 ) then 1 else 2', [ 1 ] );
test_expr( 'if( 1 .. 3 < 0 .. 2 ) then 1 else 2', [ 1 ] );
test_expr( 'if( 1 .. 3 > 0 .. 2 ) then 1 else 2', [ 1 ] );
test_expr( 'if( 1 .. 3 = 0 .. 2 ) then 1 else 2', [ 1 ] );
test_expr( 'if( 1 .. 3 != 0 .. 2 ) then 1 else 2', [ 1 ] );
test_expr( 'if( 1 .. 3 = 4 .. 7 ) then 1 else 2', [ 2 ] );
