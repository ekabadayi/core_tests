require File.dirname(__FILE__) + '/../spec_helper'

describe WikiMenuItem do
    before(:each) do
      @project = Factory.create(:project, :enabled_module_names => %w[activity])
      @current = Factory.create(:user, :login => "user1", :mail => "user1@users.com")

      User.stub!(:current).and_return(@current)
    end

    it 'should create a default wiki menu item when enabling the wiki' do
      WikiMenuItem.all.should_not be_any

      @project.enabled_modules << EnabledModule.new(:name => 'wiki')
      @project.reload

      wiki_item = @project.wiki.wiki_menu_items.first
      wiki_item.name.should eql 'Wiki'
      wiki_item.title.should eql 'Wiki'
      wiki_item.options[:index_page].should eql true
      wiki_item.options[:new_wiki_page].should eql true
    end

    describe 'it should destroy' do
      before(:each) do
        @project.enabled_modules << EnabledModule.new(:name => 'wiki')
        @project.reload

        @menu_item_1 = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                      :name    => 'Item 1',
                                      :title   => 'Item 1')

        @menu_item_2 = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                      :name    => 'Item 2',
                                      :parent_id    => @menu_item_1.id,
                                      :title   => 'Item 2')
      end

      it 'all children when deleting the parent' do
        @menu_item_1.destroy

        expect {WikiMenuItem.find(@menu_item_1.id)}.to raise_error(ActiveRecord::RecordNotFound)
        expect {WikiMenuItem.find(@menu_item_2.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end

      describe 'all items when destroying' do
        it 'the associated project' do
          @project.destroy
          WikiMenuItem.all.should_not be_any
        end

        it 'the associated wiki' do
          @project.wiki.destroy
          WikiMenuItem.all.should_not be_any
      end
    end
  end
end
