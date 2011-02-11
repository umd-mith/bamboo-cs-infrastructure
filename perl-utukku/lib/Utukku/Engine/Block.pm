package Utukku::Engine::Block;

  use Moose;
  extends 'Utukku::Engine::Expression';

  use MooseX::Types::Moose qw(ArrayRef);

  has statements => (is => 'rw', isa => ArrayRef, default => sub { [ ] });
  has ensures    => (is => 'rw', isa => ArrayRef, default => sub { [ ] });
  has catches    => (is => 'rw', isa => ArrayRef, default => sub { [ ] });

  sub run {
    my( $self, $context, $av ) = @_;

    return [ ] if $self -> noop;

    my $last;

    foreach my $s (@{$self -> statements}) {
      next unless ref $s;
      $last = $s -> run( $context, $av );
    }

    return $last;
  }

  sub invert {
    my( $self, $context, $av, $callbacks) = @_;

    return $callbacks->{done} if $self -> noop;

    my @stmts = @{$self -> statements};
    my $stmt = pop @stmts;
    my @subs = $stmt -> invert($context, $av, $callbacks);
    while( @stmts ) {
      $stmt = pop @stmts;
      my @old_subs = @subs;
      @subs = $stmt -> invert($context, $av, {
        next => sub { },
        done => sub { $_->() for @old_subs }
      });
    }
    @subs;
  }

  sub noop { 
    @{$_[0] -> statements} == 0 &&
    @{$_[0] -> ensures} == 0
  }

  sub add_statement {
    my( $self, $stmt ) = @_;

    push @{$self -> statements}, $stmt;
  }

  1;
