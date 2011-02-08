package Bamboo::Engine::TagLib;
  use Bamboo::Engine;
  use Bamboo::Engine::TagLib::Base ();
  use Bamboo::Engine::TagLib::Registry;

  use Moose::Exporter;
  
  Moose::Exporter -> setup_import_methods(
    with_meta => [ qw( 
      namespace 
      function mapping reduction consolidation
      type
    ) ],
    also => 'Moose',
  );

  sub init_meta {
    shift;
    my %p = @_;

    Moose->init_meta(%p);

    my $caller = $p{for_class};

    Moose::Util::MetaRole::apply_metaroles(
      for => $caller,
      class_metaroles => {
        class => ['MooseX::Singleton::Role::Meta::Class'],
        instance => ['MooseX::Singleton::Role::Meta::Instance'],
        constructor => ['MooseX::Singleton::Role::Meta::Method::Constructor'],
      },
    );

    Moose::Util::MetaRole::apply_base_class_roles(
      for_class => $caller,
      roles => [ 'MooseX::Singleton::Role::Object' ],
    );

    return $caller -> meta();
  }

  sub namespace {
    my($meta, $ns) = @_;

    Bamboo::Engine::TagLib::Registry -> handler($ns, $meta -> {package} -> instance);
    $meta -> {package} -> instance -> ns($ns);
  }

  sub function {
    my($meta, $name, $coderef) = @_;

    if($coderef) {
      $meta -> {package} -> instance -> functions -> {$name} = $coderef;
    }
    else {
      $meta -> {package} -> instance -> functions -> {$name};
    }
  }

  sub mapping {
    my($meta, $name, $coderef) = @_;

    if($coderef) {
      $meta -> {package} -> instance -> mappings -> {$name} = $coderef;
    }
    else {
      $meta -> {package} -> instance -> mappings -> {$name};
    }
  }

  sub reduction {
    my($meta, $name, $coderefs) = @_;

    if($coderefs) {
      $meta -> {package} -> instance -> reductions -> {$name} = $coderefs;
    }
    else {
      $meta -> {package} -> instance -> reductions -> {$name};
    }
  }

  sub consolidation {
    my($meta, $name, $coderefs) = @_;

    if($coderefs) {
      $meta -> {package} -> instance -> consolidations -> {$name."*"} = $coderefs;
    }
    else {
      $meta -> {package} -> instance -> consolidations -> {$name."*"};
    }
  }

  sub type {
    my($meta, $name, %defs) = @_;
  }
1;

__END__
=pod

=encoding utf-8

=head1 NAME

Bamboo::Engine::TagLib - Declarative syntax for Bamboo::Engine libraries

=head1 SYNOPSIS

 use Bamboo::Engine::TagLib;

 library http://www.example.com/ns/mine/1.0# {

   xmlns foo => 'http://www.example.com/ns/foo/1.0#';

   mapping foo (foo:type) {
     do_something_with($_);
   }
 }
