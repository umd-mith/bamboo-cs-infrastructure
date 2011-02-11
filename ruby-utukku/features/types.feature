@types
Feature: Type unification

  Scenario: A single type
    Given the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I unify the type f:numeric
    Then I should get the type f:numeric

  Scenario: A single type multiple times
    Given the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I unify the type f:numeric, f:numeric, f:numeric
    Then I should get the type f:numeric

  Scenario: Two types sharing a possible target type
    Given the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I unify the type f:numeric, f:numeric, f:boolean
    Then I should get the type f:numeric

  Scenario: Three types sharing a possible target type
    Given the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I unify the type f:numeric, f:numeric, f:boolean, f:string
    Then I should get the type f:string

  Scenario: Converting boolean to a string
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (f:string(f:true()))
    Then I should get 1 item
      And item 0 should be ['true']

  Scenario: Use uri-prefix
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (f:uri-prefix('f'))
    Then I should get 1 item
      And item 0 should be ["http://dh.tamu.edu/ns/fabulator/1.0#"]

  Scenario: Get the type of a boolean value
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (f:true()/@type)
    Then I should get 1 item
      And item 0 should be [f:uri('f:boolean')]

  Scenario: Get the type of a string value
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression ("foo"/@type)
    Then I should get 1 item
      And item 0 should be [f:uri('f:string')]

  Scenario: Get the type of a numeric value
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (3/@type)
    Then I should get 1 item
      And item 0 should be [f:uri('f:numeric')]

  Scenario: Get the type of a uri value
    Given a context
      And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
    When I run the expression (3/@type/@type)
    Then I should get 1 item
      And item 0 should be [f:uri('f:uri')]
