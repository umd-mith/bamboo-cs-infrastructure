package Utukku::Client::Flow;
  use Moose;

  has client => (is => 'ro', isa => 'Utukku::Client', weak_ref => 1);
  has expression => (is => 'ro', isa => 'Str');
  has iterators => (is => 'ro', isa => 'HashRef', default => sub { +{ } });
  has namespaces => (is => 'ro', isa => 'HashRef', default => sub { +{ } });
  has next => (is => 'ro', isa => 'CodeRef');
  has done => (is => 'ro', isa => 'CodeRef');
  has id => (is => 'rw', isa => 'Str');

  sub run {
    my($self) = @_;

    $self -> create unless $self -> id;
    my @coderefs;
    foreach my $nom (keys %{$self -> iterators}) {
      push @coderefs, $self -> iterators -> {$nom} -> invert({
        next => sub {
          $self -> client -> request(
            'flow.provide', {
              iterators => {
                $nom => [ $_[0] ]
              }
            }, $self -> id
          );
        },
        done => sub {
          $self -> client -> request(
            'flow.provided', {
              iterators => [ $nom ]
            }, $self -> id
          );
        }
      });
    }
    # we need to run these separately to allow multitasking
    $_ -> () for @coderefs;
  }

  sub create {
    my($self) = @_;

    $self -> id($self -> client -> request(
      'flow.create', {
      expression => $self -> expression,
      iterators => [ keys %{$self -> iterators} ],
      namespaces => $self -> namespaces
    }));
    $self -> client -> register_flow($self);
  }

  sub message {
    my($self, $class, $data) = @_;

    if($class eq 'flow.produce') {
      $self -> next -> ($_) for $data->{items};
    }
    elsif($class eq 'flow.produced') {
      $self -> terminate;
    }
  }

  sub terminate {
    my($self) = @_;

    $self -> done -> ();
    $self -> client -> request(
      'flow.close', {}, $self -> id
    );
    $self -> client -> deregister_flow($self);
  }

1;
