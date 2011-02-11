@library
Feature: Libraries

  @library
  Scenario: Using a actions and functions in a library
    Given a context
     And the prefix m as "http://example.com/ns/library"
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    Given the library
      """
        <l:library
                   xmlns:l="http://dh.tamu.edu/ns/fabulator/library/1.0#"
                   xmlns:f="http://dh.tamu.edu/ns/fabulator/1.0#"
                   l:ns="http://example.com/ns/library"
                   xmlns:my="http://example.com/ns/library"
        >
          <l:mapping l:name="double">
            <f:value-of f:select=". * 2" />
          </l:mapping>
          <l:function l:name="fctn">
            <f:value-of f:select="$1 - $2" />
          </l:function>
          <l:function l:name="fctn2">
            <f:value-of f:select="my:fctn($2, $1)" />
          </l:function>
          <l:action l:name="actn" l:has-actions="true">
            <l:attribute l:name="foo" />
            <f:value-of f:select="f:eval($actions) * 3" />
          </l:action>
          <l:action l:name="actn2" l:has-actions="true">
            <my:actn><f:value-of f:select="f:eval($actions) * 5" /></my:actn>
          </l:action>
          <l:action l:name="actn3">
            <l:attribute l:name="path" l:eval="true" />
            <f:value f:path="f:eval($path)" f:select="3" />
          </l:action>
          <l:action l:name="actn4">
            <l:attribute l:name="foo" l:eval="false" />
            <f:value f:path="/actn4foo" f:select="f:eval($foo)" />
          </l:action>
          <l:action l:name="test-select" l:has-select="true">
            <f:value f:path="/test-select" f:select="f:eval($select)" />
          </l:action>
          <l:template l:name="tmpl">
            Foo
          </l:template>
          <l:template l:name="tmpl2">
            <f:value-of f:select="$1" />
          </l:template>
          <l:template l:name="tmpl3">
            <p>
            <f:value-of f:select="$1" />
            </p>
          </l:template>
        </l:library>
      """
     And the statemachine
      """
        <f:application xmlns:f="http://dh.tamu.edu/ns/fabulator/1.0#"
                       xmlns:m="http://example.com/ns/library"
        >
          <m:actn3 m:path="/actn3" />
          <m:actn4 m:foo="bar" />
          <m:test-select f:select="123" />
        </f:application>
      """
    Then the expression (/actn3) should equal [3]
     And the expression (/actn4foo) should equal ['bar']
     And the expression (/test-select) should equal [123]
     And the expression (m:fctn(3,2)) should equal [1]
     And the expression (m:fctn2(2,3)) should equal [1]
     And the expression (m:tmpl()) should equal ['Foo']
     And the expression (m:tmpl2('Foo')) should equal ['Foo']
     And the expression (f:normalize-space(m:tmpl3('Foo'))) should equal ['<p>Foo</p>']
