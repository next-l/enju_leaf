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
        @user = User.find('admin')
        sign_in @user
      end

      it "assigns the requested user as @user" do
        get :edit
        expect(assigns(:user)).to eq(@user)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        expect(assigns(:user)).to eq(@user)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should assign the requested user as @user" do
        get :edit
        expect(assigns(:user)).to eq(@user)
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
      @attrs = {:email => 'newaddress@example.jp', :locale => 'en', :current_password => 'password'}
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          expect(assigns(:user)).to eq(@user)
        end

        it "redirects to the user" do
          put :update, :user => @attrs
          expect(assigns(:user)).to eq(@user)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          expect(assigns(:user)).to eq(@user)
        end

        it "re-renders the 'edit' template" do
          put :update, :user => @invalid_attrs
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          expect(assigns(:user)).to eq(@user)
        end

        it "redirects to the user" do
          put :update, :user => @attrs
          expect(assigns(:user)).to eq(@user)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @user" do
          put :update, :user => @invalid_attrs
          expect(assigns(:user)).to_not be_valid
        end

        it "should ignore username" do
          put :update, :user => @invalid_attrs
          expect(response).to render_template("edit")
          expect(assigns(:user).changed?).to be_truthy
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user, :password => 'password', :password_confirmation => 'password')
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :user => @attrs
          expect(assigns(:user)).to eq(@user)
          expect(response).to redirect_to(my_account_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          expect(response).to be_success
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, :user => @attrs
        end

        it "should be forbidden" do
          put :update, :user => @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :user => @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end
end
