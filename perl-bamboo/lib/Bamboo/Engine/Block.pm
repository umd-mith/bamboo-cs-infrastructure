package Bamboo::Engine::Block;

  use Moose;

  use MooseX::Types::Moose qw(ArrayRef);

  has statements => (is => 'rw', isa => ArrayRef, default => sub { [ ] });
  has ensures    => (is => 'rw', isa => ArrayRef, default => sub { [ ] });
  has catches    => (is => 'rw', isa => ArrayRef, default => sub { [ ] });

  sub run {
    my( $self, $context, $av ) = @_;

    return [ ] if $self -> noop;

    my $last;

    foreach my $s (@{$self -> statements}) {
      $last = $s -> run( $context, $av );
    }

    return $last;
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
