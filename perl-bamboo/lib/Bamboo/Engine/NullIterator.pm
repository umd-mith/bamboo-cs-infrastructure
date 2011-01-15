package Bamboo::Engine::NullIterator;
  use Moose;
  extends 'Bamboo::Engine::Iterator';

  sub any { 0 }
  sub all { 0 }

package Bamboo::Engine::NullIterator::Visitor;
  use Moose;
  extends 'Bamboo::Engine::Iterator::Visitor';

  sub next { undef };
  sub at_end { 1 };
  sub past_end { 1 };

1;
