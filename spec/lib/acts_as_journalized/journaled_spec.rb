require File.dirname(__FILE__) + '/../../spec_helper'


describe "Journalized Objects" do
  before(:each) do
    @tracker ||= Factory.create(:tracker_feature)
    @project ||= Factory.create(:project_with_trackers)
    @current = Factory.create(:user, :login => "user1", :mail => "user1@users.com")
    User.stub!(:current).and_return(@current)
  end


  it 'should work with issues' do
    @status_open ||= Factory.create(:issue_status, :name => "Open", :is_default => true)
    @issue ||= Factory.create(:issue, :project => @project, :status => @status_open, :tracker => @tracker, :author => @current)


    initial_journal = @issue.journals.first
    recreated_journal = @issue.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with news' do
    @news ||= Factory.create(:news, :project => @project, :author => @current, :title => "Test", :summary => "Test", :description => "Test")

    initial_journal = @news.journals.first
    recreated_journal = @news.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end


  it 'should work with wiki content' do
    @wiki_content ||= Factory.create(:wiki_content, :author => @current)

    initial_journal = @wiki_content.journals.first
    recreated_journal = @wiki_content.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with messages' do
    @message ||= Factory.create(:message, :content => "Test", :subject => "Test", :author => @current)

    initial_journal = @message.journals.first
    recreated_journal = @message.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with time entries' do
    @status_open ||= Factory.create(:issue_status, :name => "Open", :is_default => true)
    @issue ||= Factory.create(:issue, :project => @project, :status => @status_open, :tracker => @tracker, :author => @current)

    @time_entry ||= Factory.create(:time_entry, :issue => @issue, :project => @project, :spent_on => Time.now, :hours => 5, :user => @current, :activity => Factory.create(:time_entry_activity))

    initial_journal = @time_entry.journals.first
    recreated_journal = @time_entry.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with documents' do
    @document ||= Factory.create(:document)

    initial_journal = @document.journals.first
    recreated_journal = @document.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with attachments' do
    @attachment ||= Factory.create(:attachment, :container => Factory.create(:document), :author => @current)

    initial_journal = @attachment.journals.first
    recreated_journal = @attachment.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end

  it 'should work with changesets' do
    Setting.enabled_scm = ["Subversion"]
    @repository ||= Repository.factory("Subversion", :url => "http://svn.test.com")
    @repository.save!
    @changeset ||= Factory.create(:changeset, :committer => @current.login, :repository => @repository)

    initial_journal = @changeset.journals.first
    recreated_journal = @changeset.recreate_initial_journal!

    initial_journal.should be_identical(recreated_journal)
  end
end
