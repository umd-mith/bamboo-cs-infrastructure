package Bamboo::Shell::CommandSet;
  use Moose::Exporter;
  use Bamboo::Engine;
  use Bamboo::Shell::CommandSet::Base;

  Moose::Exporter -> setup_import_methods(
    with_meta => [
      qw(
        prefix
        command
      )
    ],
  );

  sub init_meta {
    shift;
    my %args = @_;

    my %nargs;
    $nargs{for_class} = $args{for_class}
        or Moose->throw_error("Cannot call init_meta without specifying a for_class");
    $nargs{base_class} = $args{base_class} || 'Bamboo::Shell::CommandSet::Base';
    if( exists $args{meta_name} ) {
      $nargs{meta_name} = $args{meta_name};
    }

    Moose -> init_meta( %nargs );
  }

  sub prefix {
    my($meta, $prefix) = @_;

    $meta -> {pacakge_name} -> instance -> prefix($prefix);
  }

  sub command {
    my($meta, $name, $code) = @_;

    $meta -> {package_name} -> instance -> commands -> {$name} = $code;
  }

1;
