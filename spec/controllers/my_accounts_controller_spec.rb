require 'spec_helper'

describe MyAccountsController do
  fixtures :all

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in User.find('admin')
      end

      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        expect(response).to be_success
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        expect(assigns(:user)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = User.find('admin')
        @user.profile = profile
        sign_in @user
      end

      it "assigns the requested user as @user" do
        get :edit
        expect(assigns(:profile)).to eq(@user.profile)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:librarian)
        @user.profile = profile
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        expect(assigns(:profile)).to eq(@user.profile)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:user)
        @user.profile = profile
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        expect(assigns(:profile)).to eq(@user.profile)
        expect(response).to be_success
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        get :edit
        expect(assigns(:user)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @attrs = {:user_attributes => {:email => 'newaddress@example.jp', :current_password => 'password'}, :locale => 'en'}
      @invalid_attrs = {:user_attributes => {:username => ''}, :user_number => '日本語'}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:admin, :password => 'password', :password_confirmation => 'password')
        @user.profile = profile
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, profile: @attrs
        end

        it "assigns the requested user as @user" do
          put :update, profile: @attrs
          expect(assigns(:profile)).to eq(@user.profile)
        end

        it "redirects to the user" do
          put :update, profile: @attrs
          expect(assigns(:profile)).to eq(@user.profile)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, profile: @invalid_attrs
          expect(assigns(:profile)).to eq(@user.profile)
        end

        it "re-renders the 'edit' template" do
          put :update, profile: @invalid_attrs
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:librarian, :password => 'password', :password_confirmation => 'password')
        @user.profile = profile
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, profile: @attrs
        end

        it "assigns the requested user as @user" do
          put :update, profile: @attrs
          expect(assigns(:profile)).to eq(@user.profile)
        end

        it "redirects to the user" do
          put :update, profile: @attrs
          expect(assigns(:profile)).to eq(@user.profile)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @user" do
          put :update, profile: @invalid_attrs
          # user_numberの変更は無視される
          #expect(assigns(:profile)).to_not be_valid
          expect(assigns(:profile)).to be_valid
          expect(response).to be_success
        end

        it "should ignore username" do
          put :update, profile: @invalid_attrs
          expect(response).to render_template("edit")
          expect(assigns(:profile).changed?).to be_falsy
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:user, :password => 'password', :password_confirmation => 'password')
        @user.profile = profile
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, profile: @attrs
        end

        it "assigns the requested user as @user" do
          put :update, profile: @attrs
          expect(assigns(:profile)).to eq(@user.profile)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, profile: @invalid_attrs
          expect(response).to be_success
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, profile: @attrs
        end

        it "should be forbidden" do
          put :update, profile: @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, profile: @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end
end
