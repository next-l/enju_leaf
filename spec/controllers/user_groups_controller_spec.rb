require 'spec_helper'

describe UserGroupsController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:user_group)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:user_group)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all user_groups as @user_groups" do
        get :index
        assigns(:user_groups).should eq(UserGroup.order(:position))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all user_groups as @user_groups" do
        get :index
        assigns(:user_groups).should eq(UserGroup.order(:position))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all user_groups as @user_groups" do
        get :index
        assigns(:user_groups).should eq(UserGroup.order(:position))
      end
    end

    describe "When not logged in" do
      it "assigns all user_groups as @user_groups" do
        get :index
        assigns(:user_groups).should eq(UserGroup.order(:position))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :show, id: user_group.id
        assigns(:user_group).should eq(user_group)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :show, id: user_group.id
        assigns(:user_group).should eq(user_group)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :show, id: user_group.id
        assigns(:user_group).should eq(user_group)
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :show, id: user_group.id
        assigns(:user_group).should eq(user_group)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_group as @user_group" do
        get :new
        assigns(:user_group).should_not be_valid
        expect(response).to be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested user_group as @user_group" do
        get :new
        assigns(:user_group).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user_group as @user_group" do
        get :new
        assigns(:user_group).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_group as @user_group" do
        get :new
        assigns(:user_group).should be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :edit, id: user_group.id
        assigns(:user_group).should eq(user_group)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :edit, id: user_group.id
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :edit, id: user_group.id
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_group as @user_group" do
        user_group = FactoryGirl.create(:user_group)
        get :edit, id: user_group.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created user_group as @user_group" do
          post :create, user_group: @attrs
          assigns(:user_group).should be_valid
        end

        it "redirects to the created patron" do
          post :create, user_group: @attrs
          expect(response).to redirect_to(assigns(:user_group))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_group as @user_group" do
          post :create, user_group: @invalid_attrs
          assigns(:user_group).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, user_group: @invalid_attrs
          expect(response).to render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created user_group as @user_group" do
          post :create, user_group: @attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @attrs
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_group as @user_group" do
          post :create, user_group: @invalid_attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created user_group as @user_group" do
          post :create, user_group: @attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @attrs
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_group as @user_group" do
          post :create, user_group: @invalid_attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created user_group as @user_group" do
          post :create, user_group: @attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_group as @user_group" do
          post :create, user_group: @invalid_attrs
          assigns(:user_group).should be_nil
        end

        it "should be forbidden" do
          post :create, user_group: @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @user_group = FactoryGirl.create(:user_group)
      @attrs = valid_attributes
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested user_group" do
          put :update, id: @user_group.id, user_group: @attrs
        end

        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @attrs
          assigns(:user_group).should eq(@user_group)
        end

        it "moves its position when specified" do
          put :update, id: @user_group.id, user_group: @attrs, :move => 'lower'
          expect(response).to redirect_to(user_groups_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @invalid_attrs
          expect(response).to render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested user_group" do
          put :update, id: @user_group.id, user_group: @attrs
        end

        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @attrs
          assigns(:user_group).should eq(@user_group)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested user_group" do
          put :update, id: @user_group.id, user_group: @attrs
        end

        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @attrs
          assigns(:user_group).should eq(@user_group)
          expect(response).to be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @invalid_attrs
          expect(response).to be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user_group" do
          put :update, id: @user_group.id, user_group: @attrs
        end

        it "should be forbidden" do
          put :update, id: @user_group.id, user_group: @attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_group as @user_group" do
          put :update, id: @user_group.id, user_group: @invalid_attrs
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user_group = FactoryGirl.create(:user_group)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested user_group" do
        delete :destroy, id: @user_group.id
      end

      it "redirects to the user_groups list" do
        delete :destroy, id: @user_group.id
        expect(response).to redirect_to(user_groups_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user_group" do
        delete :destroy, id: @user_group.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_group.id
        expect(response).to be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user_group" do
        delete :destroy, id: @user_group.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_group.id
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_group" do
        delete :destroy, id: @user_group.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_group.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
