#
# Allows definition of a lib as XSM stuff -- the glue between the core
# engine and the lib definition
#

# need a way to specify a library entry type -- to support grammars

# library ns: http://dh.tamu.edu/ns/fabulator/1.0#
#<f:library f:ns="">
#  <action name=''>
#    <attribute name='' type='' as='' />  (could be type='expression')
#    actions...
#  </action>
#
# <structure name=''>
#   <attribute ... />
#   <element ... />
#   actions
# </structure>
#
#  <function name=''>
#    actions...
#  </function>
#
#  <type name=''>
#    <op name=''>
#      actions...
#    </op>
#    <to name='' weight=''>
#      actions...
#    </to>
#    <from name='' weight=''>
#      actions...
#    </from>
#  </type>
#
#  <filter name=''>
#     actions...
#  </filter>
#
#  <constraint name=''>
#    actions...
#  </constraint>
#</library>


module Utukku::Engine::Lib

  require 'utukku/engine/lib/structurals'

  class LibLib < Utukku::Engine::TagLib
    namespace Utukku::Engine::NS::LIB

    structural :library, Structurals::Lib
    structural :structural, Structurals::Structural
    structural :action, Structurals::Action
    structural :attribute, Structurals::Attribute
    structural :function, Structurals::Function
    structural :mapping, Structurals::Mapping
    structural :reduction, Structurals::Reduction
    structural :consolidation, Structurals::Consolidation
    structural :template, Structurals::Template
    #structural :type, Structurals::Type
    #structural :filter, Structurals::Filter
    #structural :constraint, Structurals::Constraint

    presentations do
    end
  end
end
