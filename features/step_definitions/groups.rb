Given /^there is a group named "(.*?)" with the following members:$/ do |name, table|
  group = Factory.create(:group, :lastname => name)

  table.raw.flatten.each do |login|
    group.users << User.find_by_login!(login)
  end
end

When /^I delete the "([^"]*)" membership$/ do |group_name|
  membership = member_for_login(group_name)
  step %Q(I follow "Delete" within "#member-#{membership.id}")
end

When /^I delete "([^"]*)" from the group$/ do |login|
  user = User.find_by_login!(login)
  step %Q(I follow "Delete" within "#user-#{user.id}")
end
