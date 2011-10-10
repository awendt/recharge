@holidays
Feature: Holiday support in calendars
In order to get count the vacation days correctly
As a user
I want holidays to be considered

@javascript
  Scenario: Displaying active holidays
    When I go to the "2011" calendar
    Then I should see "13" active holidays

    When I toggle holiday on "20110106"
    Then I should see "12" active holidays

    When I toggle holiday on "20110106"
    Then I should see "13" active holidays

@javascript
  Scenario: Vacation days not counting holidays
    When I go to the "2011" calendar
    And I select vacation on "20110106"
    Then I should see a big fat "0" as vacation day count

    When I toggle holiday on "20110106"
    Then I should see a big fat "1" as vacation day count

    When I toggle holiday on "20110106"
    Then I should see a big fat "0" as vacation day count

@javascript
  Scenario: Saving holidays along with the vacation
    When I go to the "2011" calendar
    Then I should see "13" active holidays

    When I toggle holiday on "20110106"
    And I select vacation on "20110106"
    And I press "Save"
    Then I should see "12" active holidays

    When I follow next year's link
    Then I should not see vacation days
    Then "20120106" should be an active holiday

    When I follow previous year's link
    Then I should see a vacation day on "20110106"
    Then "20110106" should not be an active holiday
