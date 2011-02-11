package Utukku::Engine::TagLib::Remote;
  use MooseX::Singleton;

  use Utukku::Engine::ReductionIterator;
  use Utukku::Engine::MapIterator;
  use Utukku::Engine::NullIterator;
  use Utukku::Client::FlowIterator;

  has ns             => ( is => 'rw' );
  has functions      => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has reductions     => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has consolidations => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has mappings       => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );

  has client         => ( isa => 'Utukku::Client', is => 'rw' );

  sub function_to_iterator {
    my($self, $name, $args) = @_;

    return Utukku::Engine::NullIterator -> new unless $self -> client;

    my %iterators;
    my @vars;

    # we want to do the interfacing to the remote system via flows
    if( $name =~ /\*$/ ) { # it's a consolidation
      $iterators{'arg'} = @$args > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
      push @vars, 'arg';
    }
    elsif( $self -> reductions -> {$name} ) {
      $iterators{'arg'} = @$args > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
      push @vars, 'arg';
    }
    elsif( $self -> mappings -> {$name} ) {
      $iterators{'arg'} = @$args > 1 ? Utukku::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
      push @vars, 'arg';
    }
    elsif( $self -> functions -> {$name} ) {
      my $i = 0;
      for my $a (@$args) {
        $iterators{'arg_' . $i} = $args->[$i];
        push @vars, 'arg_'. $i;
        $i += 1;
      }
    }
    else {
       return Utukku::Engine::NullIterator -> new;
    }
    Utukku::Client::FlowIterator -> new(
      expression => 'x:' . $name . '(' . (@vars > 0 ? '$' : '').join(', $', @vars). ')',
      namespaces => { x => $self -> ns },
      iterators => \%iterators,
      client => $self -> client,
    );
  }

1;
