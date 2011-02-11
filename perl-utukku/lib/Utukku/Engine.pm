package Utukku::Engine;
  use Moose;

  use Utukku::Engine::Parser;
  use Utukku::Engine::Block;

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

Utukku::Engine - Compute engine common across Utukku components

=head1 SYNOPSIS

=head1 DESCRIPTION
