Feature: Viewing calendars
In order to get started right away
As a visitor
I want to see a calendar on the homepage

@javascript
  Scenario: Creating a calendar shows a friendly bookmark reminder, updating does not
    When I go to the "2011" calendar
    Then I should not see a popover
    And I select vacation from "20110110" to "20110114"
    And I save the calendar
    Then I should see "Lesezeichen" in a popover
    When I select vacation from "20110117" to "20110118"
    Then I should not see a popover

    When I save the calendar
    Then I should not see a popover

@javascript
  Scenario: Naming calendars
    When I go to the "2012" calendar
    Then I should see "Recharge" within "h1"
    And I should see "Recharge" as document title

    When I select vacation from "20120116" to "20120120"
    And I save the calendar
    Then I should see "Mein Kalender" within "h1"
    And I should see "Mein Kalender" as document title

    When I rename the calendar to "Mein toller Kalender"
    Then I should not see "Mein Kalender" within "h1"
    But I should see "Mein toller Kalender" within "h1"
    And I should see "Mein toller Kalender" as document title