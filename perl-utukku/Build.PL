use Module::Build;
use strict;
use warnings;

my $class = Module::Build->subclass(
  class => "Module::Build::Utukku",
  code => <<'SUBCLASS' );

sub ACTION_parser {
  my $self = shift;
  # build parser and move it to lib/Utukku/Engine/Parser.pm
  # -v is for development - outputs a engine-parser.output file
  system(qw(/usr/local/bin/eyapp -s -v -l -m Utukku::Engine::Parser engine-parser.eyp));
  system(qw(/bin/mv Parser.pm lib/Utukku/Engine/Parser.pm));
}

SUBCLASS

my $builder = $class -> new(
  module_name        => 'Utukku',
  author             => 'James Smith <jsmith@cpan.org>',
  dist_version_from  => 'lib/Utukku.pm',
  abstract_from      => 'lib/Utukku.pm',
  dist_abstract      => 'lib/Utukku.pm',
  license            => 'perl',
  build_requires     => {
    'Test::More'     => '',
    'Module::Build'  => '',
  },
  test_requires      => {
    'Expect'         => '',
  },
  author_requires    => {
    'Parse::Eyapp'   => '1.178',
  },
  requires           => {
    'Moose'          => '1.21',
    'MooseX::Types'  => '0.25',
    'MooseX::Singleton' => '0',
    'MooseX::Getopt'  => '0',
    'MooseX::SimpleConfig' => '0',
    'Math::BigRat'   => '0.26',
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
