# For convenience, these features require redmine_costs to work
# Otherwise, refactor to use custom fields instead of cost entries
Feature: Issue Sum Calculations for Currency

  Background: With overall costs beeing summable
    Given there is a standard project named "Sum Project"
    And I am admin
    When I am on the issues tab of the settings page
    When I check "issue_list_summable_columns_overall_costs"
    And I click on "Save"

  @javascript
  Scenario: Should calculate an overall sum for a standard issue query
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    Then I should see "300.00 EUR" in the overall sum

  @javascript
  Scenario: Should tick the checkbox on query edit if we previously displayed Sums
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    And I click on "Save"
    And I fill in "TestQuery" for "query_name"
    And I click on "Save"
    And I am on the issues index page for the project called "Sum Project"
    And I click on "TestQuery"
    Then the "display_sums" checkbox should be checked
    And I click on "Edit"
    Then the "query[display_sums]" checkbox should be checked

  @javascript
  Scenario: Should not tick the checkbox on query edit if we did not previously display Sums
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I click on "Apply"
    And I click on "Save"
    And I fill in "TestQuery" for "query_name"
    And I click on "Save"
    And I am on the issues index page for the project called "Sum Project"
    And I click on "TestQuery"
    Then the "display_sums" checkbox should not be checked
    And I click on "Edit"
    Then the "query[display_sums]" checkbox should not be checked

  @javascript
  Scenario: Should tick the checkbox on query save if we previously displayed Sums
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    And I click on "Save"
    Then the "query[display_sums]" checkbox should be checked

  @javascript
  Scenario: Should not tick the checkbox on query save if we did not previously display Sums
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I click on "Apply"
    And I click on "Save"
    Then the "query[display_sums]" checkbox should not be checked

  @javascript
  Scenario: Should calculate an overall sum for a grouped issue query with multiple groups
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "developer" has 1 issue with the following:
      | subject  | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | developer |
      | hours | 20        |
    And the user "designer" has 1 issue with the following:
      | subject  | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | designer |
      | hours | 30       |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
      | Labor Costs   |
      | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    Then I should see "600.00 EUR" in the overall sum
    And I toggle the Options fieldset
    And I select "Assignee" from "group_by"
    And I click on "Apply"
    Then I should see "600.00 EUR" in the overall sum
    And I should see "100.00 EUR" in the grouped sum
    And I should see "200.00 EUR" in the grouped sum
    And I should see "300.00 EUR" in the grouped sum

  @javascript
  Scenario: Should calculate an overall sum for a grouped issue query with a single group
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject  | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 20      |
    And the user "manager" has 1 issue with the following:
      | subject  | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
    | user  | manager |
      | hours | 30    |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
      | Labor Costs   |
      | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    Then I should see "600.00 EUR" in the overall sum
    And I toggle the Options fieldset
    And I select "Assignee" from "group_by"
    And I click on "Apply"
    Then I should see "600.00 EUR" in the overall sum
    And I should see "600.00 EUR" in the grouped sum

  @javascript
  Scenario: Should strip floats down to a precission of 2 numbers
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has:
      | hourly rate | 10.0000001 |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    Then I should see "100.00 EUR" in the overall sum
    And I should not see "100.000001 EUR" in the overall sum
    When the user "manager" has:
      | hourly rate | 10.001 |
    And I am on the issues index page for the project called "Sum Project"
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    Then I should see "100.01 EUR" in the overall sum
    Then I should not see "100.00 EUR" in the overall sum

  @javascript
  Scenario: Should not calculate an overall sum when the column is not selected
    Given I am on the issues tab of the settings page
    And I uncheck "issue_list_summable_columns_overall_costs"
    And I click on "Save"
    And the user "manager" has 1 issue with the following:
      | subject | Some Issue |
    And the issue "Some Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Some Other Issue |
    And the issue "Some Other Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And the user "manager" has 1 issue with the following:
      | subject | Yet Another Issue |
    And the issue "Yet Another Issue" has 1 time entry with the following:
      | user  | manager |
      | hours | 10      |
    And I am on the issues index page for the project called "Sum Project"
    And I select to see columns
    | Labor Costs   |
    | Overall costs |
    And I toggle the Options fieldset
    And I check "display_sums"
    And I click on "Apply"
    # make sure the request finished because not-seeing won't wait
    Then I should see "Sum for all Issues"
    Then I should not see "300.00 EUR" in the overall sum

  Scenario: Switch the setting for a column in the admin interface
    Given I am on the issues tab of the settings page
    When I uncheck "issue_list_summable_columns_overall_costs"
    And I click on "Save"
    Then the "issue_list_summable_columns_overall_costs" checkbox should not be checked
    And the setting for "issue_list_summable_columns" should not include "overall_costs"
    When I check "issue_list_summable_columns_overall_costs"
    And I click on "Save"
    Then the "issue_list_summable_columns_overall_costs" checkbox should be checked
    And the setting for "issue_list_summable_columns" should include "overall_costs"
