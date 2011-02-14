package Utukku::Agent::FlowIterator;
  use Moose;
  extends 'Utukku::Engine::Iterator';

  has cache => (is => 'ro', isa => 'ArrayRef', default => sub { [ ] });
  has listeners => (is => 'ro', isa => 'ArrayRef', default => sub { [ ] });
  has finishers => (is => 'ro', isa => 'ArrayRef', default => sub { [ ] });
  has is_done   => (is => 'rw', isa => 'Bool', default => 0);

  sub build_async {
    my($self, $callbacks) = @_;

    sub {
      $callbacks -> {next} -> ($_) for @{$self -> cache};
      if($self -> is_done) {
        $callbacks -> done -> ();
      }
      else {
        push @{$self -> listeners}, $callbacks -> {next};
        push @{$self -> finishers}, $callbacks -> {done};
      }
    }
  }

  sub push {
    my($self, $v) = @_;

    return if $self -> is_done;

    push @{$self -> cache}, $v;
    $_ -> ($v) for @{$self -> listeners};
  }

  sub done {
    my($self) = @_;
    $self -> is_done(1);
    $_ -> () for @{$self -> finishers};
  }
    
1;
