package Bamboo::Engine;
  use Moose;

  use Bamboo::Engine::Parser;
  use Bamboo::Engine::Block;

  our %namespace_handlers;

  sub add_namespace_handler {
    my($self, $ns, $package) = @_;

    $namespace_handlers{$ns} = $package;
  }

  sub get_namespace_handler {
    my($self, $ns) = @_;

    return $namespace_handlers{$ns};
  }

1;

__END__

=head1 NAME

Bamboo::Engine - Compute engine common across Bamboo components

=head1 SYNOPSIS

=head1 DESCRIPTION
