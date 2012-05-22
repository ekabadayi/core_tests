require File.expand_path(File.dirname(__FILE__) + "/../spec_helper.rb")

describe User do
  let(:user) { Factory.build(:user) }
  let(:project) { Factory.create(:project_with_trackers) }
  let(:role) { Factory.create(:role) }
  let(:member) { Factory.build(:member, :project => project,
                                        :roles => [role],
                                        :principal => user) }
  let(:issue_status) { Factory.create(:issue_status) }
  let(:issue) { Factory.build(:issue, :tracker => project.trackers.first,
                                      :author => user,
                                      :project => project,
                                      :status => issue_status) }

  describe :assigned_issues do
    before do
      user.save!
    end

    describe "WHEN the user has an issue assigned" do
      before do
        member.save!

        issue.assigned_to = user
        issue.save
      end

      it { user.assigned_issues.should == [issue] }
    end

    describe "WHEN the user has no issue assigned" do
      before do
        member.save

        issue.save
      end

      it { user.assigned_issues.should == [] }
    end
  end
end
