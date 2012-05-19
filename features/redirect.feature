@redirect
Feature: Welcome message for redirects
In order to be aware that I need to update my bookmarks
As a user
I want to be welcomed with a message

@javascript
  Scenario: Displaying a welcome message about the new URL
    When I visit the homepage coming from the old site
    Then I should see "Lesezeichen.*aktualisieren" in a popover
    And I should be able to bookmark the site without any URL clutter
