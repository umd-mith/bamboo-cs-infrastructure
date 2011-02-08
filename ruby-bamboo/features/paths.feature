@paths
Feature: Path expressions

  Scenario: Finding the numbers
    Given a context
      And that [/a] is set to [1 .. 10]
    When I run the expression (/a)
    Then I should get 10 items

  Scenario: Finding the positive numbers
    Given a context
      And that [/a] is set to [-1 .. 10]
    When I run the expression (/a[. > 0])
    Then I should get 10 items

  Scenario: Finding the odd numbers
    Given a context
      And that [/a] is set to [1 .. 10]
    When I run the expression (/a[. mod 2 = 1])
    Then I should get 5 items
      And item 0 should be [1]
      And item 1 should be [3]
      And item 2 should be [5]
      And item 3 should be [7]
      And item 4 should be [9]

  Scenario: Finding the third odd number
    Given a context
      And that [/a] is set to [1 .. 10]
    When I run the expression (/a[. mod 2 = 1][3])
    Then I should get 1 item
      And item 0 should be [5]

  @numpred
  Scenario: Finding the third and fifth odd numbers
    Given a context
      And that [/a] is set to [1 .. 10]
    When I run the expression (/a[. mod 2 = 1][3,5])
    Then I should get 2 items
      And item 0 should be [5]
      And item 1 should be [9]

  @numpred
  Scenario: Using an expression to name a node test
    Given a context
      And that [/a] is set to [1 .. 10]
      And that [/b] is set to ['a']
    When I run the expression (/{/b}[. mod 2 = 1][3,5])
    Then I should get 2 items
      And item 0 should be [5]
      And item 1 should be [9]

  @numpred
  Scenario: Using an expression to name a node test
    Given a context
      And that [/a] is set to [1 .. 10]
    When I run the expression (/{'a'}[. mod 2 = 1][3,5])
    Then I should get 2 items
      And item 0 should be [5]
      And item 1 should be [9]

  @pred
  Scenario: Using an expression to name a node test
    Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And that [/a/a] is set to ['a']
     And that [/a/b] is set to ['bb']
     And that [/a/c] is set to ['ccc']
     And that [/a/d] is set to ['dd']
     And that [/a/e] is set to ['e']
    When I run the expression (/a/*[f:string-length(.) > 1])
    Then I should get 3 items
     And item 0 should be ['bb']
     And item 1 should be ['ccc']
     And item 2 should be ['dd']

  @pred
  Scenario: Using an expression to name a node test
    Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
     And that [/a/a] is set to ['a']
     And that [/a/b] is set to ['bb']
     And that [/a/c] is set to ['ccc']
     And that [/a/d] is set to ['dd']
     And that [/a/e] is set to ['e']
    When I run the expression (/a/*[f:not(f:string-length(.) < 2)])
    Then I should get 3 items
     And item 0 should be ['bb']
     And item 1 should be ['ccc']
     And item 2 should be ['dd']

  @array
  Scenario: Predicates after function calls
    Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (f:split('The brown faux fox fur', ' ')[f:starts-with?(., 'f')])
    Then I should get 3 items
     And item 0 should be ['faux']
     And item 1 should be ['fox']
     And item 2 should be ['fur']
