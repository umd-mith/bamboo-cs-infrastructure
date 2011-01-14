use Module::Build;
use strict;
use warnings;

my $class = Module::Build->subclass(
  class => "Module::Build::Bamboo",
  code => <<'SUBCLASS' );

sub ACTION_parser {
  my $self = shift;
  # build parser and move it to lib/Bamboo/Engine/Parser.pm
  system(qw(/usr/local/bin/eyapp -s -l -m Bamboo::Engine::Parser engine-parser.eyp));
  system(qw(/bin/mv Parser.pm lib/Bamboo/Engine/Parser.pm));
}

SUBCLASS

my $builder = $class -> new(
  module_name        => 'Bamboo',
  author             => 'James Smith <jsmith@cpan.org>',
  dist_version_from  => 'lib/Bamboo.pm',
  abstract_from      => 'lib/Bamboo.pm',
  dist_abstract      => 'lib/Bamboo.pm',
  license            => 'perl',
  build_requires     => {
    'Test::More'     => '',
    'Module::Build'  => '',
  },
  author_requires    => {
    'Parse::Eyapp'   => '1.178',
  },
  requires           => {
    'Moose'          => '1.21',
    'MooseX::Types'  => '0.25',
    'Protocol::WebSocket' => '0.0004',
    'JSON::XS'       => '2.3',
    'Data::UUID'     => '1.217',
    'POE'            => '1.294',
  },
  recursive_test_files => 1,
  create_makefile_pl => 'traditional',
  meta_merge         => {
    resources => {
      homepage => 'http://github.com/umd-mith/bamboo-cs-infrastructure',
      repository => 'git://github.com/umd-mith/bamboo-cs-infrastructure.git',
    }
  }
);

$builder -> create_build_script;
