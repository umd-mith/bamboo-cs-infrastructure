if RUBY_VERSION < '1.9'
  $KCODE = 'u'
else
  Encoding.default_external = Encoding:UTF_8
  Encoding.default_internal = Encoding:UTF_8
end

module Utukku
  VERSION = '0.0.1'
end
