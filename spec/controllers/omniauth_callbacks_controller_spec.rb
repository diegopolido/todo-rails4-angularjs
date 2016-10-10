require 'spec_helper'

describe OmniauthCallbacksController, "handle facebook authentication callback" do
  
  describe "#annonymous user" do
    context "when facebook email doesn't exist in the system" do
      before(:each) do
        stub_env_for_omniauth

        get :facebook
        @user = User.where(:email => "ghost@nobody.com").first
      end

      it { @user.should_not be_nil }

      it "should create authentication with facebook id" do
        authentication = User.where(:provider => "facebook", :uid => "1234").first
        authentication.should_not be_nil
      end

      it { should be_user_signed_in }

      it { response.should redirect_to root_path }
    end
    
    context "when facebook email already exist in the system used by another provider" do
      before(:each) do
        stub_env_for_omniauth
        
        User.create!(:email => "ghost@nobody.com", :password => "my_secret", :provider => :google_oauth2)
        get :facebook
      end
      
      it { expect(response).to redirect_to new_user_registration_path }
      it { flash[:notice].should == "Could not authenticate you from Facebook because \"E-mail already used by another provider.\"."}
    end
  end
  
  describe "#logged in user" do
    context "when user don't have facebook authentication" do
      before(:each) do
        stub_env_for_omniauth

        user = User.create!(:email => "user@example.com", :password => "my_secret")
        sign_in user

        get :facebook
      end

      it "should add facebook authentication to current user" do
        user = User.where(:email => "user@example.com").first
        user.should_not be_nil
        fb_authentication = User.where(:provider => "facebook").first
        fb_authentication.should_not be_nil
        fb_authentication.uid.should == "1234"
      end

      it { should be_user_signed_in }

      it { response.should redirect_to root_path }
      
      it { flash[:notice].should == "Successfully authenticated from Facebook account."}
    end
    
    context "when user already connect with facebook" do
      before(:each) do
        stub_env_for_omniauth
        
        user = User.create!(:email => "ghost@nobody.com", :password => "my_secret", :provider => "facebook", :uid => "1234")
        sign_in user

        get :facebook
      end
      
      it "should not add new facebook authentication" do
        user = User.where(:email => "ghost@nobody.com").first
        user.should_not be_nil
        fb_authentications = User.where(:provider => "facebook")
        fb_authentications.count.should == 1
      end
      
      it { should be_user_signed_in }
      
      it { flash[:notice].should == "Successfully authenticated from Facebook account." }
      
      it { expect(response).to redirect_to root_path }
      
    end
  end
  
end

def stub_env_for_omniauth
  # This a Devise specific thing for functional tests. See https://github.com/plataformatec/devise/issues/closed#issue/608
  request.env["devise.mapping"] = Devise.mappings[:user]

  request.env["omniauth.auth"] = OmniAuth::AuthHash.new({
    "provider"=>"facebook",
    "uid"=> "1234",
    "info" => {
      "email" => "ghost@nobody.com"
    }
  })
end