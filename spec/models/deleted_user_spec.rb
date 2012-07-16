require File.expand_path(File.dirname(__FILE__) + "/../spec_helper.rb")

describe DeletedUser do
  let(:user) { DeletedUser.new }

  describe :admin do
    it { user.admin.should be_false }
  end

  describe :logged? do
    it { user.should_not be_logged }
  end

  describe :name do
    it { user.name.should == I18n.t(:label_deleted_user) }
  end

  describe :mail do
    it { user.mail.should be_nil }
  end

  describe :time_zone do
    it { user.time_zone.should be_nil }
  end

  describe :rss_key do
    it { user.rss_key.should be_nil }
  end

  describe :destroy do
    it { user.destroy.should be_false }
  end

  describe :available_custom_fields do
    before do
      Factory.create(:user_custom_field)
    end

    it { user.available_custom_fields.should == [] }
  end

  describe :create do
    describe "WHEN creating a second deleted user" do
      let(:u1) { Factory.build(:deleted_user) }
      let(:u2) { Factory.build(:deleted_user) }

      before do
        u1.save
        u2.save
      end

      it { u1.should_not be_new_record }
      it { u2.should be_new_record }
      it { u2.errors[:base].should == 'A DeletedUser already exists.' }
    end
  end

  describe :valid do
    describe "WHEN no login, first-, lastname and mail is provided" do
      let(:user) { DeletedUser.new }

      it { user.should be_valid }
    end
  end

  describe :first do
    describe "WHEN a deleted user already exists" do
      let(:user) { Factory.build(:deleted_user) }

      before do
        user.save!
      end

      it { DeletedUser.first.should == user }
    end

    describe "WHEN no deleted user exists" do
      it { DeletedUser.first.is_a?(DeletedUser).should be_true }
      it { DeletedUser.first.should_not be_new_record }
    end
  end
end
