require File.dirname(__FILE__) + '/../spec_helper'

describe WikiMenuItemsController do
  before do
    User.destroy_all
    Role.destroy_all

    @project = Factory.create(:project)
    @project.reload # project contains wiki by default


    @params = {}
    @params[:project_id] = @project.id
    page = Factory.create(:wiki_page, :wiki => @project.wiki)
    @params[:id] = page.title
  end

  describe 'w/ valid auth' do
    it 'renders the edit action' do
      admin_user = Factory.create(:admin)

      User.stub!(:current).and_return admin_user
      permission_role = Factory.create(:role, :name => "accessgranted", :permissions => [:manage_wiki_menu])
      member = Factory.create(:member, :principal => admin_user, :user => admin_user, :project => @project, :roles => [permission_role])

      get 'edit', @params

      response.should be_success
    end
  end

  describe 'w/o valid auth' do

    it 'be forbidden' do
      User.stub!(:current).and_return Factory.create(:user)

      get 'edit', @params

      response.status.should == "403 Forbidden"
    end
  end
end
