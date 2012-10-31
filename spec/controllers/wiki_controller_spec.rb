require File.dirname(__FILE__) + '/../spec_helper'

describe WikiController do
  describe 'routes' do
    it 'should connect GET /projects/:project_id/wiki/new to wiki/new' do
      params_from(:get, '/projects/abc/wiki/new').should == {
        :controller => 'wiki',
        :action => 'new',
        :project_id => 'abc'
      }
    end

    it 'should connect GET /projects/:project_id/wiki/:id/new to wiki/new_child' do
      params_from(:get, '/projects/abc/wiki/def/new').should == {
        :controller => 'wiki',
        :action => 'new_child',
        :project_id => 'abc',
        :id => 'def'
      }
    end

    it 'should connect POST /projects/:project_id/wiki/new to wiki/create' do
      params_from(:post, '/projects/abc/wiki/new').should == {
        :controller => 'wiki',
        :action => 'create',
        :project_id => 'abc'
      }
    end

    it 'should contect POST /projects/:project_id/wiki/:id/preview to wiki/preview' do
      params_from(:post, '/projects/abc/wiki/def/preview').should == {
        :controller => 'wiki',
        :action => 'preview',
        :project_id => 'abc',
        :id => 'def'
      }
    end

    it 'should contect POST /projects/:project_id/wiki/preview to wiki/preview' do
      params_from(:post, '/projects/abc/wiki/preview').should == {
        :controller => 'wiki',
        :action => 'preview',
        :project_id => 'abc'
      }
    end
  end

  describe 'actions' do
    before do
      @controller.stub!(:set_localization)

      @role = Factory.create(:non_member)
      @user = Factory.create(:admin)

      User.stub!(:current).and_return @user

      @project = Factory.create(:project)
      @project.reload # to get the wiki into the proxy



      # creating pages
      @existing_page = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                                  :title   => 'ExisitingPage')

      # creating page contents
      Factory.create(:wiki_content, :page_id   => @existing_page.id,
                                    :author_id => @user.id)
    end

    shared_examples_for "a 'new' action" do
      it 'assigns @project to the current project' do
        get_page

        assigns[:project].should == @project
      end

      it 'assigns @page to a newly created wiki page' do
        get_page

        assigns[:page].should be_new_record
        assigns[:page].should be_kind_of WikiPage
        assigns[:page].wiki.should == @project.wiki
      end

      it 'assigns @content to a newly created wiki content' do
        get_page

        assigns[:content].should be_new_record
        assigns[:content].should be_kind_of WikiContent
        assigns[:content].page.should == assigns[:page]
      end

      it 'renders the new action' do
        get_page

        response.should render_template 'new'
      end
    end

    describe 'new' do
      let(:get_page) { get 'new', :project_id => @project }

      it_should_behave_like "a 'new' action"
    end

    describe 'new_child' do
      let(:get_page) { get 'new_child', :project_id => @project, :id => @existing_page.title }

      it_should_behave_like "a 'new' action"

      it 'sets the parent page for the new page' do
        get_page

        assigns[:page].parent.should == @existing_page
      end

      it 'renders 404 if used with an unknown page title' do
        get 'new_child', :project_id => @project, :id => "foobar"

        response.status.should == "404 Not Found"
      end
    end

    describe 'create' do
      describe 'successful action' do
        it 'redirects to the show action' do
          post 'create',
               :project_id => @project,
               :page => {:title => "abc"},
               :content => {:text => "h1. abc"}

          response.should redirect_to :action => 'show', :project_id => @project, :id => 'Abc'
        end

        it 'saves a new WikiPage with proper content' do
          post 'create',
               :project_id => @project,
               :page => {:title => "abc"},
               :content => {:text => "h1. abc"}

          page = @project.wiki.pages.find_by_title 'Abc'
          page.should_not be_nil
          page.title.should == 'Abc'
          page.content.text.should == 'h1. abc'
        end
      end

      describe 'unsuccessful action' do
        it 'renders "wiki/new"' do
          post 'create',
               :project_id => @project,
               :page => {:title => ""},
               :content => {:text => "h1. abc"}

          response.should render_template('new')
        end

        it 'assigns project to work with new template' do
          post 'create',
               :project_id => @project,
               :page => {:title => ""},
               :content => {:text => "h1. abc"}

          assigns[:project].should == @project
        end

        it 'assigns wiki to work with new template' do
          post 'create',
               :project_id => @project,
               :page => {:title => ""},
               :content => {:text => "h1. abc"}

          assigns[:wiki].should == @project.wiki
          assigns[:wiki].should_not be_new_record
        end

        it 'assigns page to work with new template' do
          post 'create',
               :project_id => @project,
               :page => {:title => ""},
               :content => {:text => "h1. abc"}

          assigns[:page].should be_new_record
          assigns[:page].wiki.project.should == @project
          assigns[:page].title.should == ""
          assigns[:page].should_not be_valid
        end

        it 'assigns content to work with new template' do
          post 'create',
               :project_id => @project,
               :page => {:title => ""},
               :content => {:text => "h1. abc"}

          assigns[:content].should be_new_record
          assigns[:content].page.wiki.project.should == @project
          assigns[:content].text.should == 'h1. abc'
        end
      end
    end
  end

  describe 'view related stuff' do
    integrate_views

    before :each do
      @controller.stub!(:set_localization)
      Setting.stub!(:login_required?).and_return(false)

      @role = Factory.create(:non_member)
      @user = Factory.create(:admin)


      @anon = User.anonymous.nil? ? Factory.create(:anonymous) : User.anonymous

      Role.anonymous.update_attributes :name => I18n.t(:default_role_anonymous),
                                       :permissions => [:view_wiki_pages]

      User.stub!(:current).and_return @user

      @project = Factory.create(:project)
      @project.reload # to get the wiki into the proxy

      # creating pages
      @page_default = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                     :title   => 'Wiki')
      @page_with_content = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                                      :title   => 'PagewithContent')
      @page_without_content = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                                      :title   => 'PagewithoutContent')
      @redirected_page = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                                    :title   => 'TargetTitle')
      @unrelated_page = Factory.create(:wiki_page, :wiki_id => @project.wiki.id,
                                                   :title   => 'UnrelatedPage')

      # creating redirects
      @redirect = Factory.create(:wiki_redirect, :wiki_id      => @project.wiki.id,
                                                 :title        => 'Source_Title',
                                                 :redirects_to => 'Target_Title')

      # creating page contents
      Factory.create(:wiki_content, :page_id   => @page_default.id,
                                    :author_id => @user.id)
      Factory.create(:wiki_content, :page_id   => @page_with_content.id,
                                    :author_id => @user.id)
      Factory.create(:wiki_content, :page_id   => @redirected_page.id,
                                    :author_id => @user.id)
      Factory.create(:wiki_content, :page_id   => @unrelated_page.id,
                                    :author_id => @user.id)

      # creating some child pages
      @children = {}
      [@page_with_content, @redirected_page].each do |page|
        child_page = Factory.create(:wiki_page, :wiki_id   => @project.wiki.id,
                                                :parent_id => page.id,
                                                :title     => page.title + " child")
        Factory.create(:wiki_content, :page_id => child_page.id,
                                      :author_id => @user.id)

        @children[page] = child_page
      end
    end

    describe '- main menu links' do
      before do
        @main_menu_item_for_page_with_content = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                                               :name    => 'Item for Page with Content',
                                                               :title   => @page_with_content.title)

        @main_menu_item_with_redirect = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                                       :name    => 'Item with Redirect',
                                                       :title   => @redirect.title)

        @main_menu_item_for_new_wiki_page = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                                           :name    => 'Item for new WikiPage',
                                                           :title   => 'NewWikiPage')
      end

      describe '- default wiki menu item' do
        it 'is active, when default start page is selected' do
          get 'show', :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag 'a.Wiki.selected'
          end
        end

        it "is active on parents item, when new page is shown" do
          get 'new', :id => @page_with_content.title, :project_id => @project.identifier

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag '#main-menu' do
            with_tag "a.#{@main_menu_item_for_page_with_content.item_class}.selected"
          end
        end

        it 'is active, when an index page is shown' do
          get 'index', :id => 'Wiki', :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag 'a.Wiki.selected'
          end
        end

        it 'is inactive, when a different wiki page is shown' do
          get 'show', :id => @main_menu_item_for_page_with_content.title, :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag 'a.Wiki'
            without_tag 'a.Wiki.selected'
          end
        end
      end

      shared_examples_for 'all custom wiki menu items' do
        it 'is inactive, when default start page is shown' do
          get 'show', :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag "a.#{@wiki_menu_item.item_class}"
            without_tag "a.#{@wiki_menu_item.item_class}.selected"
          end
        end

        it "is inactive, when an unrelated page is shown" do
          get 'show', :id => @unrelated_page.title, :project_id => @project.id

          response.should be_success
          #response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag "a.#{@wiki_menu_item.item_class}"
            without_tag "a.#{@wiki_menu_item.item_class}.selected"
          end
        end

        it "is inactive, when another custom wiki menu item's page is shown" do
          get 'show', :id => @other_wiki_menu_item.title, :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag "a.#{@wiki_menu_item.item_class}"
            without_tag "a.#{@wiki_menu_item.item_class}.selected"
          end
        end

        it 'is active, when the given custom wiki menu item is shown' do
          get 'show', :id => @wiki_menu_item.title, :project_id => @project.id

          response.should be_success
          response.should have_exactly_one_selected_menu_item_in(:project_menu)

          response.should have_tag('#main-menu') do
            with_tag "a.#{@wiki_menu_item.item_class}.selected"
          end
        end
      end

      describe '- custom wiki menu item pointing to a saved wiki page' do
        before do
          @wiki_menu_item = @main_menu_item_for_page_with_content
          @other_wiki_menu_item = @main_menu_item_for_new_wiki_page
          @child_page = @children[@page_with_content]
        end

        it_should_behave_like 'all custom wiki menu items'
      end

      describe '- custom wiki menu item pointing to a redirect' do
        before do
          @wiki_menu_item = @main_menu_item_with_redirect
          @other_wiki_menu_item = @main_menu_item_for_new_wiki_page
          @child_page = @children[@redirected_page]
        end

        it_should_behave_like 'all custom wiki menu items'
      end

      describe '- custom wiki menu item pointing to a new wiki page' do
        before do
          @wiki_menu_item = @main_menu_item_for_new_wiki_page
          @other_wiki_menu_item = @main_menu_item_for_page_with_content
        end

        it_should_behave_like 'all custom wiki menu items'
      end

      describe '- wiki_menu_item containing special chars only' do
        before do
          @wiki_menu_item = Factory.create(:wiki_menu_item, :wiki_id => @project.wiki.id,
                                                :name    => '?',
                                                :title   => 'Help')
          @other_wiki_menu_item = @main_menu_item_for_page_with_content
        end

        it_should_behave_like 'all custom wiki menu items'
      end
    end

    describe '- wiki sidebar' do
      include ActionView::Helpers

      describe 'configure menu items link' do
        describe 'on a show page' do
          describe "being authorized to configure menu items" do
            it 'is visible' do
              get 'show', :project_id => @project.id

              response.should be_success

              response.should have_tag '#content' do
                with_tag "a", "Configure menu item"
              end
            end
          end

          describe "being unauthorized to configure menu items" do
            before do
              User.stub!(:current).and_return @anon
            end

            it 'is invisible' do
              get 'show', :project_id => @project.id

              response.should be_success

              response.should have_tag '#content' do
                without_tag "a", "Configure menu item"
              end
            end
          end
        end
      end

      describe 'new child page link' do
        describe 'on an index page' do
          describe "being authorized to edit wiki pages" do
            it 'is invisible' do
              get 'index', :project_id => @project.id

              response.should be_success

              response.should have_tag '#content' do
                without_tag "a", "Create new child page"
              end
            end
          end

          describe "being unauthorized to edit wiki pages" do
            before do
              User.stub!(:current).and_return @anon
            end

            it 'is invisible' do
              get 'index', :project_id => @project.id

              response.should be_success

              response.should have_tag '#content' do
                without_tag "a", "Create new child page"
              end
            end
          end
        end

        describe 'on a wiki page' do
          describe "being authorized to edit wiki pages" do
            describe "with a wiki page present" do
              it "is visible" do
                get 'show', :id => @page_with_content.title, :project_id => @project.identifier

                response.should be_success

                response.should have_tag '#content' do
                  with_tag "a[href=#{wiki_new_child_path(:project_id => @project, :id => @page_with_content.title)}]",
                           "Create new child page"
                end
              end
            end


            describe "with no wiki page present" do
              it 'is invisible' do
                get 'show', :id => 'i-am-a-ghostpage', :project_id => @project.identifier

                response.should be_success

                response.should have_tag '#content' do
                  without_tag "a[href=#{wiki_new_child_path(:project_id => @project, :id => 'i-am-a-ghostpage')}]",
                           "Create new child page"
                end
              end
            end
          end

          describe "being unauthorized to edit wiki pages" do
            before do
              User.stub!(:current).and_return @anon
            end

            it 'is invisible' do
              get 'show', :id => @page_with_content.title, :project_id => @project.identifier

              response.should be_success

              response.should have_tag '#content' do
                without_tag "a", "Create new child page"
              end
            end
          end
        end
      end

      describe 'new page link' do
        describe 'on an index page' do
          describe "being authorized to edit wiki pages" do
            it 'is visible' do
              get 'index', :project_id => @project.id

              response.should be_success

              response.should have_tag '.menu_root' do
                with_tag "a[href=#{wiki_new_child_path(:project_id => @project, :id => 'Wiki')}]",
                         "Create new child page"
              end
            end
          end

          describe "being unauthorized to edit wiki pages" do
            before do
              User.stub!(:current).and_return @anon
            end

            it 'is invisible' do
              get 'index', :project_id => @project.id

              response.should be_success

              response.should have_tag '.menu_root' do
                without_tag "a", "Create new child page"
              end
            end
          end
        end

        describe 'on a wiki page' do
          describe "being authorized to edit wiki pages" do
            it 'is visible' do
              get 'show', :id => @page_with_content.title, :project_id => @project.identifier

              response.should be_success

              response.should have_tag '.menu_root' do
                with_tag "a[href=#{wiki_new_child_path(:project_id => @project, :id => 'Wiki')}]",
                         "Create new child page"
              end
            end
          end

          describe "being unauthorized to edit wiki pages" do
            before do
              User.stub!(:current).and_return @anon
            end

            it 'is invisible' do
              get 'show', :id => @page_with_content.title, :project_id => @project.identifier

              response.should be_success

              response.should have_tag '.menu_root' do
                without_tag "a", "Create new child page"
              end
            end
          end
        end
      end
    end
  end
end
