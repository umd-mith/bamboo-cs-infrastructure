#! perl -w

package My::TestLib;
  use Moose;
  extends 'Bamboo::Engine::TagLib::Base';

  use Bamboo::Engine::TagLib;
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
    $_ -> () for $it -> invert({
      next => sub { push @results, $_[0] },
      done => sub {
        is_deeply(\@results, $expected_vals, $function);
      }
    });
  }

  ok(__PACKAGE__ -> can('namespace'));

  namespace 'http://www.example.com/ns/test/1.0#';

  is(__PACKAGE__ -> instance -> ns, 'http://www.example.com/ns/test/1.0#');
  is(Bamboo::Engine::TagLib::Registry -> handler('http://www.example.com/ns/test/1.0#'), __PACKAGE__ -> instance);

  mapping double => sub {
    $_[0] * 2;
  };

  ok(is_CodeRef(__PACKAGE__ -> instance -> mappings -> {double}));

  test_function('double', [
    Bamboo::Engine::ConstantIterator -> new( values => [1, 2, 3] )
  ], 'Bamboo::Engine::MapIterator',
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
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 100
    )
  ], 'Bamboo::Engine::ReductionIterator', [ 100 ] );
    
  reduction sum => sub {
    my $n = 0;
    +{
      next => sub { $n += $_[0] },
      done => sub { $n }
    }
  };

  consolidation count => reduction 'sum';

  ok(is_CodeRef(__PACKAGE__ -> instance -> consolidations -> {'count*'}));

  test_function('count*', [
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Bamboo::Engine::ReductionIterator', [ 15 ] );

  test_function('count*', [
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    ),
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Bamboo::Engine::ReductionIterator', [ 30 ] );

  function foo => sub {
    Bamboo::Engine::ConstantIterator -> new( values => [ 'foo' ] )
  };

  
  ok(is_CodeRef(__PACKAGE__ -> instance -> functions -> {foo}));

  test_function('foo', [
    Bamboo::Engine::ConstantRangeIterator -> new(
      begin => 1, end => 5
    )
  ], 'Bamboo::Engine::ConstantIterator', [ 'foo' ] );
