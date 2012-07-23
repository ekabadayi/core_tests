Given /^there is a standard project named "([^\"]*)"$/ do |name|
  steps %Q{
    Given there is 1 project with the following:
      | Name | #{name} |
    And there is a role "Manager"
    And there is a role "Developer"
    And there is a role "Designer"
    And the role "Manager" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And the role "Developer" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And the role "Designer" may have the following rights:
      | view_own_hourly_rate     |
      | view_hourly_rates        |
      | view_cost_rates          |
      | view_own_time_entries    |
      | view_own_cost_entries    |
      | view_cost_entries        |
      | view_time_entries        |
    And there is 1 user with:
      | Login        | manager   |
      | Firstname    | Mac       |
      | Lastname     | Moneysack |
      | default rate | 10.00     |
    And there is 1 user with:
      | Login        | developer |
      | Firstname    | Alan      |
      | Lastname     | Kay       |
      | default rate | 10.00     |
    And there is 1 user with:
      | Login        | designer |
      | Firstname    | Tom      |
      | Lastname     | Kelley   |
      | default rate | 10.00    |
    And the user "manager" is a "Manager" in the project "#{name}"
    And the user "designer" is a "Designer" in the project "#{name}"
    And the user "developer" is a "Developer" in the project "#{name}"
  }
end

Then /^[iI] should (not )?see "([^\"]*)" in the overall sum(?:s)?$/ do |negative, sum|
  steps "Then I should #{negative}see \"#{sum}\" within \"tr.sum.all\""
end

Then /^[iI] should (not )?see "([^\"]*)" in the grouped sum(?:s)?$/ do |negative, sum|
  steps "Then I should #{negative}see \"#{sum}\" within \"tr.sum.grouped\""
end

Then /^[iI] toggle the [oO]ptions fieldset$/ do
  page.execute_script <<-JS
    f = $$("fieldset").without($("filters")).first();
    toggleFieldset($(f).select("legend").first());
  JS
end

Then /^the setting for "(.*?)" should include "(.*?)"$/ do |setting_name, value|
  Setting.send(setting_name).should include(value)
end

Then /^the setting for "(.*?)" should not include "(.*?)"$/ do |setting_name, value|
  Setting.send(setting_name).should_not include(value)
end
