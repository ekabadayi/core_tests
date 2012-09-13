Given /^the project "(.*?)" has a wiki menu item with the following:$/ do |project_name, table|
  item = Factory.build(:wiki_menu_item)
  send_table_to_object(item, table)
  item.wiki = Project.find_by_name(project_name).wiki
  item.save!
end
