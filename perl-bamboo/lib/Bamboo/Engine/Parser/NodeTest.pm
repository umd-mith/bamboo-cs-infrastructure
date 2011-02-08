package Bamboo::Engine::Parser::NodeTest;
  use Moose;

  use Bamboo::Engine::FilterIterator;

  has name => ( is => 'rw', isa => 'Str', required => 1 );

  sub run {
    my($self, $context, $av) = @_;

    Bamboo::Engine::FilterIterator -> new(
      iterator => $context -> node -> children_iterator,
      filter   => sub { $_[0] -> name eq $self -> name }
    );
  }

1;

__END__
