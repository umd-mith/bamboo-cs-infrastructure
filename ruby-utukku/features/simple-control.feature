Feature: Simple Flow Control

  Scenario: 'If' with a true condition
   Given a context
   When I run the expression (if ( 1 = 1 ) then 'foo' else 'bar')
   Then I should get 1 item
     And item 0 should be ['foo']

  Scenario: 'If' with a false condition
   Given a context
   When I run the expression (if ( 1 = 0 ) then 'foo' else 'bar')
   Then I should get 1 item
     And item 0 should be ['bar']

  @conj
  Scenario: Or
   Given a context
   When I run the expression (if ( 1 = 0 or 2 * 2 = 4 ) then 'foo' else 'bar')
   Then I should get 1 item
     And item 0 should be ['foo']

  @conj
  Scenario: And
   Given a context
   When I run the expression (if ( 1 = 0 and 2 * 2 = 4 ) then 'foo' else 'bar')
   Then I should get 1 item
     And item 0 should be ['bar']
