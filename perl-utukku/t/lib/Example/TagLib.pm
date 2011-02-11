package Example::TagLib;
  use Moose;
  extends 'Utukku::Engine::TagLib::Base';

  use Utukku::Engine::TagLib;

  namespace 'http://www.example.com/echo/1.0#';

  mapping double => sub {
    $_[0] * 2;
  };

1;
