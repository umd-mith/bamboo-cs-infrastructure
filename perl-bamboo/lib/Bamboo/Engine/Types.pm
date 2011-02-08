package Bamboo::Engine::Types;

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

class_type Node, { class => 'Bamboo::Engine::Memory::Node' };

class_type Context, { class => 'Bamboo::Engine::Context' };

class_type Type, { class => 'Bamboo::Engine::Type' };

class_type Iterator, { class => 'Bamboo::Engine::Iterator' };

class_type Expression, { class => 'Bamboo::Engine::Expression' };

class_type TagLib, { class => 'Bamboo::Engine::TagLib::Base' };

coerce Type,
  from ArrayRef,
   via { Bamboo::Engine::Type -> new(namespace => $_->[0], name => $_->[1]) };

1;

__END__

=head1 NAME

Bamboo::Engine::Types - Various Moose types used in Bamboo::Engine

=head1 SYNOPSIS

 use Bamboo::Engine::Types qw( Node Type );

=head1 DESCRIPTION
