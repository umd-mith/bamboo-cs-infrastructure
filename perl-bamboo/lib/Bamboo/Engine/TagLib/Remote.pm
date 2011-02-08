package Bamboo::Engine::TagLib::Remote;
  use MooseX::Singleton;

  use Bamboo::Engine::ReductionIterator;
  use Bamboo::Engine::MapIterator;
  use Bamboo::Engine::NullIterator;
  use Bamboo::Client::FlowIterator;

  has ns             => ( is => 'rw' );
  has functions      => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has reductions     => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has consolidations => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );
  has mappings       => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );

  has client         => ( isa => 'Bamboo::Client', is => 'rw' );

  sub function_to_iterator {
    my($self, $name, $args) = @_;

    return Bamboo::Engine::NullIterator -> new unless $self -> client;

    my %iterators;
    my @vars;

    # we want to do the interfacing to the remote system via flows
    if( $name =~ /\*$/ ) { # it's a consolidation
      $iterators{'arg'} = @$args > 1 ? Bamboo::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
      push @vars, 'arg';
    }
    elsif( $self -> reductions -> {$name} ) {
      $iterators{'arg'} = @$args > 1 ? Bamboo::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
      push @vars, 'arg';
    }
    elsif( $self -> mappings -> {$name} ) {
      $iterators{'arg'} = @$args > 1 ? Bamboo::Engine::UnionIterator -> new( iterators => $args ) : $args->[0];
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
       return Bamboo::Engine::NullIterator -> new;
    }
    Bamboo::Client::FlowIterator -> new(
      expression => 'x:' . $name . '(' . (@vars > 0 ? '$' : '').join(', $', @vars). ')',
      namespaces => { x => $self -> ns },
      iterators => \%iterators,
      client => $self -> client,
    );
  }

1;
