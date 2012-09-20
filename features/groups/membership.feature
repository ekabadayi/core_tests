Feature: Group memberships
  Background:
    Given there is 1 project with the following:
      | name        | project1 |
      | identifier  | project1 |
    And there is 1 user with the following:
      | login     | bob        |
      | firstname | Bob        |
      | Lastname  | Bobbit     |
    And there is 1 user with the following:
      | login     | alice      |
      | firstname | Alice      |
      | lastname  | Wonderland |
    And there is 1 group with the following:
      | name      | group1     |
    And there is a role "manager"
    And there is a role "developer"
    And the role "manager" may have the following rights:
      | manage_members |
    And the user "bob" is a "manager" in the project "project1"

  Scenario: Adding a group with members to a project
    Given the group "group1" has the following members:
      | alice     |
    And I am already logged in as "bob"
    When I go to the members tab of the settings page of the project "project1"
    And I add the principal "group1" as a member with the roles:
      | developer |
    Then I should see the principal "group1" as a member with the roles:
      | developer |
    And I should see the principal "alice" as a member with the roles:
      | developer |

  Scenario: Adding members to a group after the group has been added to the project adds the users to the project
    Given the group "group1" is a "developer" in the project "project1"
    And I am already logged in as "admin"
    When I go to the edit page of the group called "group1"
    And I follow "Users" within ".tabs"
    And I add the user "alice" to the group
    And I go to the members tab of the settings page of the project "project1"
    Then I should see the principal "group1" as a member with the roles:
      | developer |
    And I should see the principal "alice" as a member with the roles:
      | developer |

  @javascript
  Scenario: Removing a group from a project removes it's members (users) as well if they have no roles of their own
    Given the group "group1" has the following members:
      | alice     |
    And the group "group1" is a "developer" in the project "project1"
    And I am already logged in as "bob"
    When I go to the members tab of the settings page of the project "project1"
    And I follow the delete link of the project member "group1"
    Then I should not see the principal "group1" as a member
    And I should not see the principal "alice" as a member

  @javascript
  Scenario: Removing a group from a project leaves a member if he has other roles besides those inherited from the group
    Given the group "group1" has the following members:
      | alice     |
    And the user "alice" is a "manager" in the project "project1"
    And the group "group1" is a "developer" in the project "project1"
    And I am already logged in as "bob"
    When I go to the members tab of the settings page of the project "project1"
    And I follow the delete link of the project member "group1"
    Then I should not see the principal "group1" as a member
    And I should see the principal "alice" as a member with the roles:
      | manager |


