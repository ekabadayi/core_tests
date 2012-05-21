Feature: User deletion

  @javascript
  Scenario: A user can delete himself
    Given there is 1 user with the following:
      | login     | bob |
    And I am already logged in as "bob"
    When I go to the my account page
    And I follow "Delete account"
    And I press "Delete"
    And I accept the "Are you sure you want to delete the account?" alert
    Then I should see "Account successfully deleted"
    And I should be on the login page
