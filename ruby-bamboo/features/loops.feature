Feature: Loops

 Scenario: 'For' with a single variable
   Given a context
   When I run the expression (for $i in 1 .. 3 return $i)
   Then I should get 3 items
     And item 0 should be [1]
     And item 1 should be [2]
     And item 2 should be [3]

 Scenario: 'Some' with a single variable
   Given a context
   When I run the expression (some $i in 1 .. 3 satisfies $i mod 2 = 1)
   Then I should get 1 items
     And item 0 should be true

 Scenario: 'Every' with a single variable
   Given a context
   When I run the expression (every $i in 1 .. 3 satisfies $i mod 2 = 1)
   Then I should get 1 items
     And item 0 should be false

 @for
 Scenario: 'For' with two variables
   Given a context
   When I run the expression (for $i in 1 .. 3, $j in 2 to 4 return $i*$j)
   Then I should get 9 items

 @for
 Scenario: 'For' within a sum
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
   When I run the expression (f:sum(for $i in 1 to 3, $j in 2 to 4 return $i*$j))
   Then I should get 1 item
     And item 0 should be [54]

 @with
 Scenario: 'For' with annotation
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
   When I run the expression (for $i in 1 to 3 return $i with ./line := 4)
   Then I should get 3 items
     And item 0 should be [1]
     And item 1 should be [2]
     And item 2 should be [3]

 @with
 Scenario: 'For' with annotation
   Given a context
     And the prefix f as "http://dh.tamu.edu/ns/fabulator/1.0#"
   When I run the expression ((for $i in 1 to 3 return $i with ./line := 4)/line)
   Then I should get 3 items
     And item 0 should be [4]
     And item 1 should be [4]
     And item 2 should be [4]
