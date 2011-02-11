package Utukku::Engine::Types;

use MooseX::Types
  -declare => [qw(
    Node
    Type
    Iterator
    Expression
    Context
    TagLib
  )];

use MooseX::Types::Moose qw/Int HashRef Str ArrayRef/;

class_type Node, { class => 'Utukku::Engine::Memory::Node' };

class_type Context, { class => 'Utukku::Engine::Context' };

class_type Type, { class => 'Utukku::Engine::Type' };

class_type Iterator, { class => 'Utukku::Engine::Iterator' };

class_type Expression, { class => 'Utukku::Engine::Expression' };

class_type TagLib, { class => 'Utukku::Engine::TagLib::Base' };

coerce Type,
  from ArrayRef,
   via { Utukku::Engine::Type -> new(namespace => $_->[0], name => $_->[1]) };

1;

__END__

=head1 NAME

Utukku::Engine::Types - Various Moose types used in Utukku::Engine

=head1 SYNOPSIS

 use Utukku::Engine::Types qw( Node Type );

=head1 DESCRIPTION
