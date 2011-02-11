package Utukku::Engine::Parser::FunctionCall;
  use Moose;
  extends 'Utukku::Engine::Expression';

  use Utukku::Engine::Types qw( Expression Context );
  use MooseX::Types::Moose qw( ArrayRef Str );

  has 'function'  => ( is => 'rw', isa => Str );
  has 'args' => ( is => 'rw', isa => 'Maybe[ArrayRef]', default => sub { [ ] } );
  has 'context' => ( is => 'rw', isa => Context );

  sub run {
    my($self, $context, $av) = @_;

    $context -> with_ctx($self -> context, sub {
      my($context) = @_;
      $context -> function_to_iterator($self -> function, [ map { $_ -> run($context, $av) } @{$self -> args} ]);
    });
  }

1;
