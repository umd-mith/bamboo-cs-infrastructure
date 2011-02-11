Feature: Simple Math

  Scenario Outline: binary math
    Given a context
      And that [/a] is set to [<a>]
      And that [/b] is set to [<b>]
    When I run the expression (a <op> b)
    Then I should get 1 item
      And item 0 should be [<ans>]

    Examples:
      |  a |  op | b | ans |
      |  2 |  +  | 1 |  3  |
      |  2 |  -  | 1 |  1  |
      |  3 |  *  | 7 | 21  |
      | 30 | div | 6 |  5  |
      | 15 | mod | 4 |  3  |

  @bool
  Scenario Outline: boolean ops
    Given a context
      And that [/a] is set to [<a>]
      And that [/b] is set to [<b>]
    When I run the expression (a <op> b)
    Then I should get 1 item
      And item 0 should be <ans>

    Examples:
      |  a  |  op | b   | ans   |
      |  0  |  =  | 1   | false |
      |  2  |  =  | 2   | true  |
      | 'a' |  =  | 'a' | true  |
      | 'a' |  =  | 'b' | false |
      | 'a' |  =  | 1   | false |
      |  1  |  <  | 'a' | true  |
