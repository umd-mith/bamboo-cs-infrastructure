package Bamboo::Shell::CommandSet::Base;
  use MooseX::Singleton;

  has prefix => ( isa => 'Str', is => 'rw' );
  has commands => ( isa => 'HashRef', is => 'rw', default => sub { +{ } } );

  sub init_commands {
    my($self, $shell) = @_;

    $shell -> add_handler($self -> prefix, $self);
  }

  sub immediate {
    my($self, $shell, $command, @bits) = @_;

    if( $self -> commands -> {$command} ) {
      $self -> commands -> {$command} -> ($self, $shell, @bits);
    }
    else {
      0;
    }
  }

1;
