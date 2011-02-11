package Utukku::Engine::TagLib::Base;
#  use MooseX::Singleton;
  use Moose;

  use Utukku::Engine::ReductionIterator;
  use Utukku::Engine::MapIterator;
  use Utukku::Engine::NullIterator;

  has ns             => ( is => 'rw' );
  has functions      => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has reductions     => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has consolidations => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has mappings       => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );

  sub instance {
    my($self) = @_;

    no strict 'refs';

    my $class = ref $self || $self;
    ${"${class}::INSTANCE"} ||= $class -> new;
  }

  sub function_to_iterator {
    my($self, $name, $args) = @_;

    my $n = scalar(@$args);

    if( $name =~ /\*$/ ) { # it's a consolidation
      Utukku::Engine::ReductionIterator -> new(
        iterator => $n > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : ($n == 1 ? $args->[0] : Utukku::Engine::NullIterator -> new),
        reduction => $self -> consolidations -> {$name},
      );
    }
    elsif( $self -> reductions -> {$name} ) {
      Utukku::Engine::ReductionIterator -> new(
        iterator => $n > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : ($n == 1 ? $args->[0] : Utukku::Engine::NullIterator -> new),
        reduction => $self -> reductions -> {$name},
      );
    }
    elsif( $self -> mappings -> {$name} ) {
      Utukku::Engine::MapIterator -> new(
        iterator => $n > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : ($n == 1 ? $args->[0] : Utukku::Engine::NullIterator -> new),
        mapping => $self -> mappings -> {$name}
      );
    }
    elsif( $self -> functions -> {$name} ) {
       $self -> functions -> {$name} -> (@$args);
    }
    else {
       Utukku::Engine::NullIterator -> new;
    }
  }

1;
