Feature: User deletion

  @javascript
  Scenario: A user can delete himself
    Given there is 1 user with the following:
      | login     | bob |
    And I am already logged in as "bob"
    When I go to the my account page
    And I follow "Delete account"
    And I press "Delete"
    And I accept the alert dialog
    Then I should see "Account successfully deleted"
    And I should be on the login page

  @javascript
  Scenario: An admin can delete other users
    Given there is 1 user with the following:
      | login     | bob |
    And I am already logged in as "admin"
    When I go to the edit page of the user "bob"
    And I follow "Delete" within ".contextual"
    And I press "Delete"
    And I accept the alert dialog
    Then I should see "Account successfully deleted"
    And I should be on the index page of users
