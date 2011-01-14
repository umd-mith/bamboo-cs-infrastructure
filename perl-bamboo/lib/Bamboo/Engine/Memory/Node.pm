package Bamboo::Engine::Memory::Node;
  use Moose;

  use Bamboo::Engine::Types qw( Type Node Boolean );
  use MooseX::Types::Moose qw( Str HashRef ArrayRef );

  use Bamboo::Engine::Type;

  has 'value'        => (is => 'rw');
  has 'name'         => (is => 'rw', isa => Str);
  has 'roots'        => (is => 'rw', isa => HashRef);
  has 'type'         => (is => 'rw', isa => Type, default => sub { to_Type([ "http://dh.tamu.edu/ns/fabulator/1.0#", "string" ]) } );
  has 'children'     => (is => 'rw', isa => HashRef);
  has 'parent'       => (is => 'rw', isa => Node);
  has 'attributes'   => (is => 'ro', isa => HashRef);
  has 'is_attribute' => (is => 'rw', isa => Boolean);

  sub axis {
    my($self) = @_;
    if(defined $self -> parent) {
      return $self -> parent -> axis;
    }
    if(defined $self -> roots) {
      return (grep { $self -> roots -> { $_ } == $self } keys %{$self -> roots})[0];
    }
  }

  sub set_attribute {
    my($self, $key, $value) = @_;

    if($key eq 'type') {
      if( is_Node($value) ) {
        $self -> type = $value -> to(["http://dh.tamu.edu/ns/fabulator/1.0#", "string"]) -> value;
      }
      else {
        $self -> type = $value;
      }
    }
    else {
      if( is_Node($value) ) {
        $value = $value -> clone();
      }
      else {
        $value = __PACKAGE__ -> new(
          roots => $self -> roots,
          value => $value,
          parent => $self,
          is_attribute => 1
        );
      }
      $self -> attributes ||= { };
      $self -> attributes -> {$key} = $value;
    }
    1;
  }

  sub get_attribute {
    my($self, $key) = @_;

    return $self -> type if $key eq 'type';

    $self -> attributes ||= { };
    $self -> attributes -> {$key};
  }

  sub anon_node {
    my($self, $value, $type) = @_;

    if(is_ArrayRef($value)) {
      return __PACKAGE__ -> new(
        children => [ map { $self -> anon_node($_, $type) } @$value ],
        roots => $self -> roots
      );
    }
    elsif(is_HashRef($value)) {
      my $p = __PACKAGE__ -> new( );
      $p -> children = [
        map { 
          __PACKAGE__ -> new(
            name => $_,
            parent => $p,
            value => $value -> {$_},
          );
        } keys %$value
      ];
      return $p;
    }
    else {
      return __PACKAGE__ -> new(
        value => $value,
        type => $type
      );
    }
  }

1;

__END__
