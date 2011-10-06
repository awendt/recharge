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
