@pan
@gestures
Feature: Pan
  In order to perform swipes
  As a developer
  I want a Pan API

Background: Navigate to the scrolls page
  Given I see the scrolls tab

Scenario: Left-to-right screen pan in portrait
  When I touch the table views row
  Then I see the table views page
  When I pan left-to-right on the screen
  Then I go back to the Scrolls page

Scenario: Left-to-right screen pan in landscape
  When I touch the collection views row
  Then I see the collection views page
  And I try to rotate the home button so it is on the right
  When I pan left-to-right on the screen
  Then I go back to the Scrolls page

