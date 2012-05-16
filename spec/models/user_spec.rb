require File.expand_path(File.dirname(__FILE__) + "/../spec_helper.rb")

describe User do
  let(:user) { Factory.build(:user) }
  let(:user2) { Factory.build(:user) }
  let(:project) { Factory.create(:project_with_trackers) }
  let(:role) { Factory.create(:role) }
  let(:member) { Factory.create(:member, :project => project,
                                         :roles => [role],
                                         :principal => user) }
  let(:issue_status) { Factory.create(:issue_status) }
  let(:issue) { Factory.create(:issue, :tracker => project.trackers.first,
                                       :author => user,
                                       :project => project,
                                       :status => issue_status,
                                       :assigned_to => user) }
  let(:issue2) { Factory.create(:issue, :tracker => project.trackers.first,
                                        :author => user2,
                                        :project => project,
                                        :status => issue_status,
                                        :assigned_to => user2) }
  let(:attachment) { Factory.build(:attachment, :author => user) }

  let(:news) { Factory.create(:news, :author => user) }

  let(:comment) { Comment.create(:commented => news,
                                 :author => user,
                                 :comments => "lorem") }

  describe :destroy do
    let(:substitute_user) { DeletedUser.first }

    before do
      user.save!
    end

    describe "WHEN there is the user" do
      before do
        user.destroy
      end

      it { User.find_by_id(user.id).should be_nil }
    end

    shared_examples_for "updated journalized associated object" do
      before do
        User.current = user2
        associations.each do |association|
          associated_instance.send(association.to_s + "=", user2)
        end
        associated_instance.save!

        User.current = user # in order to have the content journal created by the user
        associated_instance.reload
        associations.each do |association|
          associated_instance.send(association.to_s + "=", user)
        end
        associated_instance.save!

        user.destroy
        associated_instance.reload
      end

      it { associated_class.find_by_id(associated_instance.id).should == associated_instance }
      it "should replace the user on all associations" do
        associations.each do |association|
          associated_instance.send(association).should == substitute_user
        end
      end
      it { associated_instance.journals.first.user.should == user2 }
      it "should update first journal changes" do
        associations.each do |association|
          associated_instance.journals.first.changes[association.to_s + "_id"].last.should == user2.id
        end
      end
      it { associated_instance.journals.last.user.should == substitute_user }
      it "should update second journal changes" do
        associations.each do |association|
          associated_instance.journals.last.changes[association.to_s + "_id"].last.should == substitute_user.id
        end
      end
    end

    shared_examples_for "created associated object" do
      before do
        associations.each do |association|
          associated_instance.send(association.to_s + "=", user)
        end
        associated_instance.save!

        user.destroy
        associated_instance.reload
      end

      it { associated_class.find_by_id(associated_instance.id).should == associated_instance }
      it "should replace the user on all associations" do
        associations.each do |association|
          associated_instance.send(association).should == substitute_user
        end
      end
    end

    shared_examples_for "created journalized associated object" do
      before do
        User.current = user # in order to have the content journal created by the user
        associations.each do |association|
          associated_instance.send(association.to_s + "=", user)
        end
        associated_instance.save!

        User.current = user2
        associated_instance.reload
        associations.each do |association|
          associated_instance.send(association.to_s + "=", user2)
        end
        associated_instance.save!

        user.destroy
        associated_instance.reload
      end

      it { associated_class.find_by_id(associated_instance.id).should == associated_instance }
      it "should keep the current user on all associations" do
        associations.each do |association|
          associated_instance.send(association).should == user2
        end
      end
      it { associated_instance.journals.first.user.should == substitute_user }
      it "should update the first journal" do
        associations.each do |association|
          associated_instance.journals.first.changes[association.to_s + "_id"].last.should == substitute_user.id
        end
      end
      it { associated_instance.journals.last.user.should == user2 }
      it "should update the last journal" do
        associations.each do |association|
          associated_instance.journals.last.changes[association.to_s + "_id"].first.should == substitute_user.id
          associated_instance.journals.last.changes[association.to_s + "_id"].last.should == user2.id
        end
      end
    end

    describe "WHEN the user has created one attachment" do
      let(:associated_instance) { Factory.build(:attachment) }
      let(:associated_class) { Attachment }
      let(:associations) { [:author] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has updated one attachment" do
      let(:associated_instance) { Factory.build(:attachment) }
      let(:associated_class) { Attachment }
      let(:associations) { [:author] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has an issue created and assigned" do
      let(:associated_instance) { Factory.build(:issue, :tracker => project.trackers.first,
                                                        :project => project,
                                                        :status => issue_status) }
      let(:associated_class) { Issue }
      let(:associations) { [:author, :assigned_to] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has an issue updated and assigned" do
      let(:associated_instance) { Factory.build(:issue, :tracker => project.trackers.first,
                                                        :project => project,
                                                        :status => issue_status) }
      let(:associated_class) { Issue }
      let(:associations) { [:author, :assigned_to] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has updated a wiki content" do
      let(:associated_instance) { Factory.build(:wiki_content) }
      let(:associated_class) { WikiContent}
      let(:associations) { [:author] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has created a wiki content" do
      let(:associated_instance) { Factory.build(:wiki_content) }
      let(:associated_class) { WikiContent }
      let(:associations) { [:author] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has created a news" do
      let(:associated_instance) { Factory.build(:news) }
      let(:associated_class) { News }
      let(:associations) { [:author] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has worked on news" do
      let(:associated_instance) { Factory.build(:news) }
      let(:associated_class) { News }
      let(:associations) { [:author] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has created a message" do
      let(:associated_instance) { Factory.build(:message) }
      let(:associated_class) { Message }
      let(:associations) { [:author] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has worked on message" do
      let(:associated_instance) { Factory.build(:message) }
      let(:associated_class) { Message }
      let(:associations) { [:author] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has created a time entry" do
      let(:associated_instance) { Factory.build(:time_entry, :project => project,
                                                             :issue => issue,
                                                             :hours => 2,
                                                             :activity => Factory.create(:time_entry_activity)) }
      let(:associated_class) { TimeEntry }
      let(:associations) { [:user] }

      it_should_behave_like "created journalized associated object"
    end

    describe "WHEN the user has worked on time_entry" do
      let(:associated_instance) { Factory.build(:time_entry, :project => project,
                                                             :issue => issue,
                                                             :hours => 2,
                                                             :activity => Factory.create(:time_entry_activity)) }
      let(:associated_class) { TimeEntry }
      let(:associations) { [:user] }

      it_should_behave_like "updated journalized associated object"
    end

    describe "WHEN the user has commented" do
      let(:news) { Factory.create(:news, :author => user) }

      let(:associated_instance) { Comment.new(:commented => news,
                                              :comments => "lorem") }

      let(:associated_class) { Comment }
      let(:associations) { [:author] }

      it_should_behave_like "created associated object"
    end


    describe "WHEN the user is a member of a project" do
      before do
        member #saving

        user.destroy
      end

      it { Member.find_by_id(member.id).should be_nil }
      it { Role.find_by_id(role.id).should == role }
      it { Project.find_by_id(project.id).should == project }
    end

    describe "WHEN the user is watching something" do
      let(:watched) { Factory.create(:wiki_content) }
      let(:watch) { Watcher.new(:user => user,
                                :watchable => watched) }

      before do
        watch.save

        user.destroy
      end

      it { Watcher.find_by_id(watch.id).should be_nil }
    end

    describe "WHEN the user has a token created" do
      let(:token) { Token.new(:user => user,
                              :action => "feeds",
                              :value => "loremipsum") }

      before do
        token.save!

        user.destroy
      end

      it { Token.find_by_id(token.id).should be_nil }
    end

    describe "WHEN the user has created a private query" do
      let(:query) { Factory.build(:private_query, :user => user) }

      before do
        query.save!

        user.destroy
      end

      it { Query.find_by_id(query.id).should be_nil }
    end

    describe "WHEN the user has created a public query" do
      let(:associated_instance) { Factory.build(:public_query) }

      let(:associated_class) { Query }
      let(:associations) { [:user] }

      it_should_behave_like "created associated object"
    end
  end
end
