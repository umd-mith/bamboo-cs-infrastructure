package Bamboo::Agent::Flow;
  use Moose;
  use Bamboo::Engine::Parser;
  use Bamboo::Engine::Context;
  use Bamboo::Agent::FlowIterator;

  has expression => (isa => 'Str', is => 'ro');
  has _expression => (isa => 'Bamboo::Engine::Expression', is => 'rw');
  has iterators => (isa => 'ArrayRef', is => 'ro', default => sub { [ ] });
  has _iterators => (isa => 'HashRef', is => 'ro', default => sub { +{ } });
  has namespaces => (isa => 'HashRef', is => 'ro', default => sub { +{ } });
  has id => (isa => 'Str', is => 'ro' );
  has agent => (isa => 'Bamboo::Agent', is => 'ro');

  sub start {
    my($self) = @_;

use Data::Dumper;
    my $context = Bamboo::Engine::Context -> new;

    for my $i (@{$self -> iterators}) {
      $self -> _iterators -> {$i} = Bamboo::Agent::FlowIterator -> new;
      $context -> var($i, $self -> _iterators -> {$i});
    }
    for my $p (keys %{$self -> namespaces}) {
      $context -> ns($p, $self -> namespaces -> {$p});
    }
    my $parser = Bamboo::Engine::Parser -> new;
    my $exp = $parser -> parse($context, $self -> expression);

    my @subs = $exp -> invert($context, 0, {
      next => sub {
        $self -> agent -> response('flow.produce', {
          items => [ $_[0] ]
        }, $self -> id);
      },
      done => sub {
        $self -> agent -> response('flow.produced', {}, $self -> id);
      }
    });
    $_ -> () for @subs;
  }

  sub provide {
    my($self, $iterators) = @_;

    for my $k ( keys %$iterators ) {
      $self -> _iterators -> {$k} -> push($iterators -> {$k});
    }
  }

  sub provided {
    my($self, $iterators) = @_;

    $self -> _iterators -> {$_} -> done() for @$iterators;
  }

  sub finish {
    my($self) = @_;

    
  }

1;
