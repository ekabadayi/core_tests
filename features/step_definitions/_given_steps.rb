Given /^the project "(.*?)" has a wiki menu item with the following:$/ do |project_name, table|
  item = Factory.build(:wiki_menu_item)
  send_table_to_object(item, table)
  item.wiki = Project.find_by_name(project_name).wiki
  item.save!
end

Given /^the project "(.*?)" has a child wiki page of "(.*?)" with the following:$/ do |project_name, parent_page_title, table|
  wiki = Project.find_by_name(project_name).wiki
  wikipage = Factory.build(:wiki_page, :wiki => wiki)

  send_table_to_object(wikipage, table)

  Factory.create(:wiki_content, :page => wikipage)

  parent_page = WikiPage.find_by_wiki_id_and_title(wiki.id, parent_page_title)
  wikipage.parent_id = parent_page.id
  wikipage.save!
end
