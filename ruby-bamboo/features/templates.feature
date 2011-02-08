@tmpl
Feature: Templates

  Scenario: Rendering a simple template
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#"></foo>
       """
   When I render the template
   Then the rendered text should equal
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#"/>
       """

  Scenario: Rendering a choice in a template
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <r:choose>
    <r:when test="f:true()">
      true
    </r:when>
    <r:otherwise>
      false
    </r:otherwise>
  </r:choose>
</foo>
       """
   When I render the template
   Then the rendered text should equal
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">


      true



</foo>
       """

  Scenario: Rendering a choice in a template
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <r:choose>
    <r:when test="f:false()">
      true
    </r:when>
    <r:otherwise>
      false
    </r:otherwise>
  </r:choose>
</foo>
       """
   When I render the template
   Then the rendered text should equal
       """
<foo xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">



      false


</foo>
       """

  Scenario: Rendering a form with captions
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form>
    <text id='foo'><caption>Foo</caption></text>
    <submission id='submit'/>
  </form>
</view>
       """
   When I render the template
    And I set the captions to:
      | path   | caption       |
      | foo    | FooCaption    |
      | submit | SubmitCaption |
   Then the rendered text should equal
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form>
    <text id="foo"><caption>FooCaption</caption></text>
    <submission id="submit"><caption>SubmitCaption</caption></submission>
  </form>
</view>
       """

  @def
  Scenario: Rendering a form with defaults
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form>
    <text id='foo'><caption>Foo</caption></text>
  </form>
</view>
       """
   When I render the template
    And I set the defaults to:
      | path   | default       |
      | foo    | FooDefault    |
   Then the rendered text should equal
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form>
    <text id="foo"><caption>Foo</caption><default>FooDefault</default></text>
  </form>
</view>
       """

  @def
  Scenario: Rendering a form with defaults
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form id='foo'>
    <text id='bar'><caption>Foo</caption></text>
    <text id='baz'><caption>Boo</caption></text>
  </form>
</view>
       """
   When I render the template
    And I set the defaults to:
      | path    | default       |
      | foo/bar | FooDefault    |
      | foo/baz | this & that   |
   Then the rendered text should equal
       """
<view xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <form id="foo">
    <text id="bar"><caption>Foo</caption><default>FooDefault</default></text>
    <text id="baz"><caption>Boo</caption><default>this &amp; that</default></text>
  </form>
</view>
       """

  @nst
  Scenario: Rendering markup with namespaces
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And the template
       """
<form xmlns="http://dh.tamu.edu/ns/fabulator/1.0#">
  <text id="foo"><caption>Foo</caption></text>
</form>
       """
   When I render the template
   Then the rendered html should equal
       """
<form type="application/x-multipart" method="POST" class="fabulator-form">
  <table class="form-content" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td class="form-caption" valign="top">
        <span class="caption">Foo</span>
      </td>
      <td class="form-element" valign="top">
        <input type="text" name="foo" size="12" value="">
      </td>
    </tr>
    </table>
</form>
       """
