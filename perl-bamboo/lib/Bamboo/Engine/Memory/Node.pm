package Bamboo::Engine::Memory::Node;
  use Moose;

  use Bamboo::Engine::Types qw( Type Node );
  use MooseX::Types::Moose qw( Str HashRef ArrayRef Bool );

  use Bamboo::Engine::Type;

  has 'value'        => (is => 'rw');
  has 'name'         => (is => 'rw', isa => Str);
  has 'roots'        => (is => 'rw', isa => HashRef);
  has 'type'         => (is => 'rw', isa => Type, default => sub { to_Type([ "http://dh.tamu.edu/ns/fabulator/1.0#", "string" ]) } );
  has 'children'     => (is => 'rw', isa => HashRef);
  has 'parent'       => (is => 'rw', isa => Node, weak_ref => 1);
  has 'attributes'   => (is => 'ro', isa => HashRef);
  has 'is_attribute' => (is => 'rw', isa => Bool);

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
      return $self -> new(
        children => [ map { $self -> anon_node($_, $type) } @$value ],
        roots => $self -> roots
      );
    }
    elsif(is_HashRef($value)) {
      my $p = $self -> new( );
      $p -> children = [
        map { 
          $self -> new(
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

  sub path {
    my($self) = @_;

    if( !$self -> parent || $self -> parent eq $self ) {
      return '';
    }
    else {
      return $self -> parent -> path . '/' . (
        $self -> is_attribute ? '@' : ''
      ) . $self -> name;
    }
  }

  sub children_iterator {
    my($self) = @_;

    Bamboo::Engine::ConstantIterator -> new(
      values => $self -> children,
    );
  }

1;

__END__
