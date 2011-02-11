package Utukku::Engine::Parser::NodeTest;
  use Moose;

  use Utukku::Engine::FilterIterator;

  has name => ( is => 'rw', isa => 'Str', required => 1 );

  sub run {
    my($self, $context, $av) = @_;

    Utukku::Engine::FilterIterator -> new(
      iterator => $context -> node -> children_iterator,
      filter   => sub { $_[0] -> name eq $self -> name }
    );
  }

1;

__END__
