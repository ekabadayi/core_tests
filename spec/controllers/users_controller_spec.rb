require File.expand_path(File.dirname(__FILE__) + "/../spec_helper.rb")

describe UsersController do
  let(:user) { Factory.create(:user) }

  describe :routes do
    it { params_from(:get, "/users/1/deletion_info").should == { :controller => 'users', :action => 'deletion_info', :id => "1" } }

  end

  describe "GET deletion_info" do

    describe "WHEN the current user is the requested user" do
      let(:params) { { "id" => user.id.to_s } }

      before do
        @controller.stub!(:find_current_user).and_return(user)

        get :deletion_info, params
      end

      it { response.should be_success }
      it { assigns(:user).should == user }
      it { response.should render_template("deletion_info") }
    end

    describe "WHEN the current user is the anonymous user" do
      let(:params) { { "id" => User.anonymous.id.to_s } }

      before do
        @controller.stub!(:find_current_user).and_return(User.anonymous)

        get :deletion_info, params
      end

      it { response.should redirect_to({ :controller => 'account',
                                         :action => 'login',
                                         :back_url => @controller.url_for({ :controller => 'users',
                                                                            :action => 'deletion_info' }) }) }
    end
  end

  describe "POST destroy" do
    describe "WHEN the current user is the requested one" do
      let(:params) { { "id" => user.id.to_s } }

      before do
        @controller.instance_eval{ flash.stub!(:sweep) }
        @controller.stub!(:find_current_user).and_return(user)

        post :destroy, params
      end

      it { response.should redirect_to({ :controller => 'account', :action => 'login' }) }
      it { flash[:notice].should == I18n.t('account.deleted') }
    end

    describe "WHEN the current user is the anonymous user" do
      let(:params) { { "id" => User.anonymous.id.to_s } }

      before do
        @controller.stub!(:find_current_user).and_return(User.anonymous)

        post :destroy, params
      end

      # redirecting post is not possible for now
      it { response.response_code.should == 403 }
    end
  end
end
