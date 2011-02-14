package Utukku::Engine::NullIterator;
  use Moose;
  extends 'Utukku::Engine::Iterator';

  sub any { 0 }
  sub all { 0 }

  sub build_async {
    my($self, $callbacks) = @_;

    sub { $callbacks -> {done} -> () }
  }

package Utukku::Engine::NullIterator::Visitor;
  use Moose;
  extends 'Utukku::Engine::Iterator::Visitor';

  sub start { }
  sub position { 0 }
  sub next { undef }
  sub at_end { 1 }
  sub past_end { 1 }

1;
