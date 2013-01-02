Feature: Viewing calendars
In order to get started right away
As a visitor
I want to see a calendar on the homepage

  Scenario: Navigating between years
    When I go to the homepage
    Then I should see "Recharge" within "h1"
    And I should see a calendar for the current year
    And I should see links for next and previous year
    But I should not see vacation days
    
    When I follow next year's link
    Then I should see a calendar for the next year
    But I should not see vacation days

    When I go to the homepage
    And I follow previous year's link
    Then I should see a calendar for the previous year
    But I should not see vacation days

@javascript
  Scenario: Counting the days
    When I go to the "2011" calendar
    Then I should see a big fat "0" as vacation day count

    When I select vacation from "20110110" to "20110114"
    Then I should see a big fat "5" as vacation day count

    When I de-select vacation from "20110113" to "20110114"
    Then I should see a big fat "3" as vacation day count

    When I save the calendar
    Then I should see a big fat "3" as vacation day count

@javascript
  Scenario: Creating a calendar
    When I go to the "2011" calendar
    And I select vacation from "20110110" to "20110114"
    And I save the calendar
    Then I should see vacation days from "20110110" to "20110114"

    When I follow next year's link
    Then I should not see vacation days

    When I follow previous year's link
    Then I should see vacation days from "20110110" to "20110114"

@javascript
  Scenario: Creating a calendar in a year other than the current redirects correctly
    When I go to the "2010" calendar
    And I select vacation from "20100301" to "20100305"
    And I save the calendar
    Then I should see vacation days from "20100301" to "20100305"

@javascript
  Scenario: Updating an existing calendar
    When I go to the "2011" calendar
    And I select vacation from "20110110" to "20110114"
    And I save the calendar
    Then I should see vacation days from "20110110" to "20110114"

    When I follow next year's link
    Then I should not see vacation days

    When I select vacation from "20120312" to "20120315"
    And I save the calendar
    Then I should see vacation days from "20120312" to "20120315"

    When I follow previous year's link
    Then I should see vacation days from "20110110" to "20110114"

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
  Scenario: Marking days as half days
    When I go to the "2012" calendar
    And I select vacation from "20120116" to "20120120"
    Then I should see a big fat "5" as vacation day count
    When I mark vacation days on "20120116" and "20120117" as half
    Then I should see a big fat "4" as vacation day count

    When I save the calendar
    Then I should see a big fat "4" as vacation day count

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