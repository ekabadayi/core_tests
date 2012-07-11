require File.dirname(__FILE__) + '/../spec_helper'

describe Issue do
  describe 'Acts as journalized' do
    before(:each) do
      IssueStatus.delete_all
      IssuePriority.delete_all

      @status_resolved ||= Factory.create(:issue_status, :name => "Resolved", :is_default => false)
      @status_open ||= Factory.create(:issue_status, :name => "Open", :is_default => true)
      @status_rejected ||= Factory.create(:issue_status, :name => "Rejected", :is_default => false)

      @priority_low ||= Factory.create(:priority_low, :is_default => true)
      @priority_high ||= Factory.create(:priority_high)
      @tracker ||= Factory.create(:tracker_feature)
      @project ||= Factory.create(:project_with_trackers)

      @current = Factory.create(:user, :login => "user1", :mail => "user1@users.com")
      User.stub!(:current).and_return(@current)

      @user2 = Factory.create(:user, :login => "user2", :mail => "user2@users.com")


      @issue ||= Factory.create(:issue, :project => @project, :status => @status_open, :tracker => @tracker, :author => @current)
    end

    describe 'ignore blank to blank transitions' do
      it 'should not include the "nil to empty string"-transition' do
        @issue.description = nil
        @issue.save!

        @issue.description = ""
        @issue.send(:incremental_journal_changes).should be_empty
      end
    end

    describe 'Acts as journalized recreate initial journal' do
      it 'should not include certain attributes' do
        recreated_journal = @issue.recreate_initial_journal!

        recreated_journal.attributes["changes"].include?('rgt').should == false
        recreated_journal.attributes["changes"].include?('lft').should == false
        recreated_journal.attributes["changes"].include?('lock_version').should == false
        recreated_journal.attributes["changes"].include?('updated_at').should == false
        recreated_journal.attributes["changes"].include?('updated_on').should == false
        recreated_journal.attributes["changes"].include?('id').should == false
        recreated_journal.attributes["changes"].include?('type').should == false
        recreated_journal.attributes["changes"].include?('root_id').should == false
      end

      it 'should not include useless transitions' do
        recreated_journal = @issue.recreate_initial_journal!

        recreated_journal.attributes["changes"].values.each do |change|
          change.first.should_not == change.last
        end
      end

      it 'should not be different from the initially created journal by aaj' do
        # Creating four journals total
        @issue.status = @status_resolved
        @issue.assigned_to = @user2
        @issue.save!
        @issue.reload

        @issue.priority = @priority_high
        @issue.save!
        @issue.reload

        @issue.status = @status_rejected
        @issue.priority = @priority_low
        @issue.estimated_hours = 3
        @issue.remaining_hours = 43 if Redmine::Plugin.all.collect(&:id).include?(:backlogs)
        @issue.save!

        initial_journal = @issue.journals.first
        recreated_journal = @issue.recreate_initial_journal!

        initial_journal.should be_identical(recreated_journal)
      end
    end
  end
end
