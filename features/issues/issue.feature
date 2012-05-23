Feature: Issue textile quickinfo links
  Background:
    Given there is 1 project with the following:
      | name        | Parent      |
      | identifier  | parent      |
    And I am admin
    And there is 1 user with:
        | login | admin |
    And there is a role "project admin"
    And I am working in project "parent"
    And the user "admin" is a "project admin"
    And I am already logged in as "admin"
    And the project uses the following trackers:
        | Epic  |
    And there are the following issue status:
        | name        | is_closed  | is_default  |
        | New         | false      | true        |
        | In Progress | false      | false       |
    Given the user "admin" has 1 issue with the following:
        |  subject      | issue1             |
        |  due_date     | 2012-05-04         |
        |  start_date   | 2011-05-04         |
        |  tracker      | Epic               |
        |  description  | Aioli Sali Grande  |

  Scenario: Adding an issue link
    When I go to the issues/new page of the project called "parent"
    When I follow "New issue" within "#main-menu"
    And I fill in "One hash key" for "issue_subject"
    And I fill in the ID of "issue1" with 1 hash for "issue_description"
    And I press "Create"
    Then I should see an issue link for "issue1" within "div.wiki"
    When I follow the issue link with 1 hash for "issue1"
    Then I should be on the page of the issue "issue1"

  Scenario: Adding an issue quickinfo link
    When I go to the issues/new page of the project called "parent"
    When I follow "New issue" within "#main-menu"
    And I fill in "One hash key" for "issue_subject"
    And I fill in the ID of "issue1" with 2 hash for "issue_description"
    And I press "Create"
    Then I should see a quickinfo link for "issue1" within "div.wiki"
    When I follow the issue link with 2 hash for "issue1"
    Then I should be on the page of the issue "issue1"

  Scenario: Adding an issue quickinfo link with description
    When I go to the issues/new page of the project called "parent"
    When I follow "New issue" within "#main-menu"
    And I fill in "One hash key" for "issue_subject"
    And I fill in the ID of "issue1" with 3 hash for "issue_description"
    And I press "Create"
    Then I should see a quickinfo link with description for "issue1" within "div.wiki"
    When I follow the issue link with 3 hash for "issue1"
    Then I should be on the page of the issue "issue1"
