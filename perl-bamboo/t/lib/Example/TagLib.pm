package Example::TagLib;
  use Moose;
  extends 'Bamboo::Engine::TagLib::Base';

  use Bamboo::Engine::TagLib;

  namespace 'http://www.example.com/echo/1.0#';

  mapping double => sub {
    $_[0] * 2;
  };

1;
