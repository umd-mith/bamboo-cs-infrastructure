package Bamboo::Engine::Types;

use MooseX::Types
  -declare => [qw(
    Boolean
    Node
    Type
    Iterator
    Expression
    Context
  )];

use MooseX::Types::Moose qw/Int HashRef Str ArrayRef/;

subtype Boolean,
     as Int;

coerce Boolean,
  from Int,
   via { $_ != 0 };

class_type Node, { class => 'Bamboo::Engine::Memory::Node' };

class_type Context, { class => 'Bamboo::Engine::Memory::Context' };

class_type Type, { class => 'Bamboo::Engine::Type' };

class_type Iterator, { class => 'Bamboo::Engine::Iterator' };

class_type Expression, { class => 'Bamboo::Engine::Expression' };

coerce Type,
  from ArrayRef,
   via { Bamboo::Engine::Type -> new(namespace => $_->[0], name => $_->[1]) };

1;

__END__

=head1 NAME

Bamboo::Engine::Types - Various Moose types used in Bamboo::Engine

=head1 SYNOPSIS

 use Bamboo::Engine::Types qw( Boolean Node Type );

=head1 DESCRIPTION
