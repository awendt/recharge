@holidays
Feature: Holiday support in calendars
In order to get count the vacation days correctly
As a user
I want holidays to be considered

@javascript
  Scenario: Displaying active holidays
    When I go to the "2011" calendar
    Then I should see 6 active holidays

    When I toggle holiday on "20111003"
    Then I should see 5 active holidays

    When I toggle holiday on "20111003"
    Then I should see 6 active holidays

@javascript
  Scenario: Vacation days not counting holidays
    When I go to the "2011" calendar
    And I select vacation on "20111003"
    Then I should see a big fat "0" as vacation day count

    When I toggle holiday on "20111003"
    Then I should see a big fat "1" as vacation day count

    When I toggle holiday on "20111003"
    Then I should see a big fat "0" as vacation day count

@javascript
  Scenario: Saving holidays along with the vacation
    When I go to the "2011" calendar
    Then I should see 6 active holidays

    When I toggle holiday on "20111003"
    And I select vacation on "20111003"
    And I press "Kalender behalten"
    Then I should see 5 active holidays

    When I follow next year's link
    Then I should not see vacation days
    Then "20121003" should be an active holiday

    When I follow previous year's link
    Then I should see a vacation day on "20111003"
    And "20111003" should not be an active holiday

@javascript
  Scenario: Switching regions on a blank calendar
    When I go to the "2011" calendar
    Then I should see 6 active holidays

    When I switch to region "Bayern"
    Then I should see 10 active holidays

    When I switch to region "Schleswig-Holstein"
    Then I should see 6 active holidays

@javascript
  Scenario: Vacation count is updated when switching regions
    When I go to the "2011" calendar
    Then I should see 6 active holidays

    When I toggle holiday on "20110106"
    Then I should see a big fat "1" as vacation day count

    When I switch to region "Bayern"
    Then I should see a big fat "0" as vacation day count

    When I switch to region "Berlin"
    Then I should see a big fat "1" as vacation day count

@javascript
  Scenario: Holidays should be saved after switching regions
    When I go to the "2011" calendar
    And I switch to region "Bayern"
    And I select vacation on "20110110"
    And I press "Kalender behalten"

    Then I should see 10 active holidays
    And "20110106" should be an active holiday