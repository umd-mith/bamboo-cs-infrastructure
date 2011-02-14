#! perl -w

package My::TestLib;
  use Moose;
  extends 'Utukku::Engine::TagLib::Base';

  use Utukku::Engine::TagLib;
  use MooseX::Types::Moose qw( CodeRef );

  use Test::More tests => 5 + 3*4;

  sub test_function {
    my($function, $args, $expected_type, $expected_vals) = @_;

    my $it = __PACKAGE__ -> instance -> function_to_iterator(
      $function,
      $args
    );

    isa_ok($it, $expected_type);

    my @results;
    $it -> async({
      next => sub { push @results, $_[0] },
      done => sub {
        is_deeply(\@results, $expected_vals, $function);
      }
    });
  }

  ok(__PACKAGE__ -> can('namespace'));

  namespace 'http://www.example.com/ns/test/1.0#';

  is(__PACKAGE__ -> instance -> ns, 'http://www.example.com/ns/test/1.0#');
  is(Utukku::Engine::TagLib::Registry -> handler('http://www.example.com/ns/test/1.0#'), __PACKAGE__ -> instance);

  mapping double => sub {
    $_[0] * 2;
  };

  ok(is_CodeRef(__PACKAGE__ -> instance -> mappings -> {double}));

  test_function('double', [
    Utukku::Engine::ConstantIterator -> new( values => [1, 2, 3] )
  ], 'Utukku::Engine::MapIterator',
    [ 2, 4, 6 ]
  );

  reduction count => sub {
    my $n = 0;
    +{
      next => sub { $n += 1 },
      done => sub { $n }
    }
  };

  ok(is_CodeRef(__PACKAGE__ -> instance -> reductions -> {count}));

  test_function('count', [
    Utukku::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 100
    )
  ], 'Utukku::Engine::ReductionIterator', [ 100 ] );
    
  reduction sum => sub {
    +{
      init => sub { 0 },
      next => sub { $_[0] += $_[1] },
      done => sub { $_[0] }
    }
  };

  consolidation count => reduction 'sum';

  ok(is_CodeRef(__PACKAGE__ -> instance -> consolidations -> {'count*'}));

  test_function('count*', [
    Utukku::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Utukku::Engine::ReductionIterator', [ 15 ] );

  test_function('count*', [
    Utukku::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    ),
    Utukku::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Utukku::Engine::ReductionIterator', [ 30 ] );

  function foo => sub {
    Utukku::Engine::ConstantIterator -> new( values => [ 'foo' ] )
  };

  
  ok(is_CodeRef(__PACKAGE__ -> instance -> functions -> {foo}));

  test_function('foo', [
    Utukku::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Utukku::Engine::ConstantIterator', [ 'foo' ] );
