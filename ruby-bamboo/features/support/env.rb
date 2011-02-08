# This file makes it possible to install RubyCAS-Client as a Rails plugin.

$: << File.expand_path(File.dirname(__FILE__))+'/../../lib'

require 'bamboo/engine'
require 'bamboo/template'
require 'bamboo/engine/core'
require 'bamboo/engine/lib'
#require 'spec/expectations'
