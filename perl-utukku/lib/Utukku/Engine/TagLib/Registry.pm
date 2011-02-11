package Utukku::Engine::TagLib::Registry;
  use MooseX::Singleton;

  has handlers => ( isa => 'HashRef', is => 'ro', default => sub { +{ } } );

  sub handler {
    my($self, $ns, $class) = @_;

    return unless defined $ns;

    if( @_ == 2 ) {
      return $self -> handlers -> {$ns};
    }
    else {
      $self -> handlers -> {$ns} = $class;
    }
  }

  sub describe_namespaces {
    my($self, @namespaces) = @_;

    # return a hash
    my $conf = { };

    for my $ns (@namespaces) {
      my $h = $self -> handler($ns);

      next unless $h;

      $conf -> {$ns} = {
        mappings       => [ keys %{$h -> mappings} ],
        consolidations => [ keys %{$h -> consolidations} ],
        reductions     => [ keys %{$h -> reductions} ],
        functions      => [ keys %{$h -> functions} ],
      };
    }

    return $conf;
  }

1;
