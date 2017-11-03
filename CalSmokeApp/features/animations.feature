@animations
Feature:  Animations
In order to demonstrate that Calabash works when there are animations
As a Calabash maintainer
I want some Scenarios with views that animate

Background: Navigate to the special tab
  Given I see the special tab

@backdoor
@gestures
Scenario: Start an animation and wait for it to finish
  And I have started an animation that lasts 4 seconds
  Then I can wait for the animation to stop

@network_indicator
@backdoor
Scenario: Start the network indicator and wait for it to finish
  And I start the network indicator for 4 seconds
  Then I can wait for the indicator to stop

Scenario: Pass an unknown condition to the condition route
  When I pass an unknown condition to wait_for_condition
  Then the app should not crash
  And an error should be raised

# It is impossible to pass a nil query.  The client will substitute a '*'
Scenario: Call wait_for_animation with a nil query
  When I pass an empty query to wait_for_none_animating
  Then the app should not crash
  And an error should be raised

