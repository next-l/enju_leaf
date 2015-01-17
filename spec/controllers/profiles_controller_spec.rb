# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ProfilesController do
  fixtures :all

  describe "GET index", :solr => true do
		before do
			Profile.reindex
		end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all profiles as @profiles" do
        get :index
        assigns(:profiles).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all profiles as @profiles" do
        get :index
        assigns(:profiles).should_not be_nil
      end

      it "should get index with query" do
        get :index, :query => 'user1'
        response.should be_success
        assigns(:profiles).should_not be_empty
      end

      it "should get sorted index" do
        get :index, :query => 'user1', :sort_by => 'username', :order => 'desc'
        response.should be_success
        assigns(:profiles).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all profiles as @profiles" do
        get :index
        assigns(:profiles).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all profiles as @profiles" do
        get :index
        assigns(:profiles).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        get :show, id: profiles(:admin).id
        assigns(:profile).should eq(profiles(:admin))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user as @profile" do
        get :show, id: profiles(:librarian1).id
        assigns(:profile).should eq(profiles(:librarian1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user as @profile" do
        get :show, id: profiles(:user1).id
        assigns(:profile).should eq(profiles(:user1))
      end

      it "should redirect to my user account" do
        get :show, id: profiles(:user1).id
        assert_redirected_to my_account_url
      end

      it "should not show other user's account" do
        get :show, id: profiles(:admin).id
        assigns(:profile).should eq(profiles(:admin))
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @profile" do
        get :show, id: profiles(:admin).id
        assigns(:profile).should eq(profiles(:admin))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        get :new
        assigns(:profile).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested user as @profile" do
        get :new
        assigns(:profile).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @profile" do
        get :new
        assigns(:profile).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @profile" do
        get :new
        assigns(:profile).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @profile" do
        profile = FactoryGirl.create(:profile)
        get :edit, id: profile.id
        assigns(:profile).should eq(profile)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should assign the requested user as @profile" do
        profile = FactoryGirl.create(:profile)
        get :edit, id: profile.id
        assigns(:profile).should eq(profile)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @profile" do
        profile = FactoryGirl.create(:profile)
        get :edit, id: profile.id
        assigns(:profile).should eq(profile)
        response.should be_forbidden
      end

      it "should edit myself" do
        get :edit, id: profiles(:user1).id
        response.should redirect_to edit_my_account_url
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @profile" do
        profile = FactoryGirl.create(:profile)
        get :edit, id: profile.id
        assigns(:profile).should eq(profile)
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:profile)
      @invalid_attrs = {:user_group_id => '', :user_number => '日本語'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created user as @profile" do
          post :create, :profile => @attrs
          assigns(:profile).should be_valid
        end

        it "redirects to the created user" do
          post :create, :profile => @attrs
          response.should redirect_to(profile_url(assigns(:profile)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @profile" do
          post :create, :profile => @invalid_attrs
          assigns(:profile).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :profile => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created user as @profile" do
          post :create, :profile => @attrs
          assigns(:profile).should be_valid
        end

        it "redirects to the created user" do
          post :create, :profile => @attrs
          response.should redirect_to(profile_url(assigns(:profile)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @profile" do
          post :create, :profile => @invalid_attrs
          assigns(:profile).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :profile => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not create user" do
        post :create, profile: { :username => 'test10' }
        assigns(:profile).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not create user" do
        post :create, profile: { :username => 'test10' }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @profile = profiles(:user1)
      @attrs = {:user_group_id => '3', :locale => 'en'}
      @invalid_attrs = {:user_group_id => '', :user_number => '日本語'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested user" do
          put :update, id: @profile.id, profile: @attrs
        end

        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @attrs
          assigns(:profile).should eq(@profile)
        end

        it "redirects to the user" do
          put :update, id: @profile.id, profile: @attrs
          assigns(:profile).should eq(@profile)
          response.should redirect_to(@profile)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @invalid_attrs
          assigns(:profile).should eq(@profile)
        end

        it "re-renders the 'edit' template" do
          put :update, id: @profile, profile: @invalid_attrs
          response.should render_template("edit")
        end
      end

      it "should update other user's role" do
        put :update, id: profiles(:user1).id, profile: {:user_attributes => {:user_has_role_attributes => {:role_id => 4}, :email => profiles(:user1).user.email, :locale => 'en', :id => profiles(:user1).user.id}}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).reload
        assigns(:profile).user.role.should eq Role.where(name: 'Administrator').first
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested user" do
          put :update, id: @profile.id, profile: @attrs
        end

        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @attrs
          assigns(:profile).should eq(@profile)
        end

        it "redirects to the user" do
          put :update, id: @profile.id, profile: @attrs
          assigns(:profile).should eq(@profile)
          response.should redirect_to(@profile)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @profile" do
          put :update, id: @profile, profile: @invalid_attrs
          assigns(:profile).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, id: @profile, profile: @invalid_attrs
          response.should render_template("edit")
        end
      end

      it "should update other user" do
        put :update, id: profiles(:user1).id, profile: {:user_number => '00003', :locale => 'en', :user_group_id => 3, :library_id => 3, :note => 'test'}
        response.should redirect_to profile_url(assigns(:profile))
      end

      it "should update other user's user_group" do
        put :update, id: profiles(:user1).id, profile: {:user_group_id => 3, :library_id => 3, :locale => 'en'}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).user_group_id.should eq 3
      end

      it "should update other user's note" do
        put :update, id: profiles(:user1).id, profile: {:user_group_id => 3, :library_id => 3, :note => 'test', :locale => 'en'}
        response.should redirect_to profile_url(assigns(:profile))
        assert_equal assigns(:profile).note, 'test'
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested user" do
          put :update, id: @profile.id, profile: @attrs
        end

        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @attrs
          assigns(:profile).should be_valid
          response.should redirect_to profile_url(assigns(:profile))
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @invalid_attrs
          #assigns(:profile).should_not be_valid
          #response.should be_success
          assigns(:profile).should be_valid
          response.should redirect_to profile_url(assigns(:profile))
        end
      end

      it "should update myself" do
        put :update, id: profiles(:user1).id, profile: {keyword_list: 'test'}
        response.should redirect_to profile_url(assigns(:profile))
      end

      it "should not update my role" do
        put :update, id: profiles(:user1).id, profile: {:user_has_role_attributes => {:role_id => 4}}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).user.role.should_not eq Role.where(name: 'Administrator').first
      end

      it "should not update my user_group" do
        put :update, id: profiles(:user1).id, profile: {:user_group_id => 3, :library_id => 3}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).user_group_id.should eq 1
      end

      it "should not update my note" do
        put :update, id: profiles(:user1).id, profile: {:user_group_id => 3, :library_id => 3, :note => 'test'}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).note.should be_nil
      end

      it "should update my keyword_list" do
        put :update, id: profiles(:user1).id, profile: {:keyword_list => 'test'}
        response.should redirect_to profile_url(assigns(:profile))
        assigns(:profile).keyword_list.should eq 'test'
        assigns(:profile).user.role.name.should eq 'User'
      end

      it "should not update other user" do
        put :update, id: profiles(:user2).id, profile: { }
        assigns(:profile).should be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, id: @profile.id, profile: @attrs
        end

        it "should be forbidden" do
          put :update, id: @profile.id, profile: @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @profile" do
          put :update, id: @profile.id, profile: @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested user" do
        delete :destroy, id: profiles(:user2).id
      end

      it "redirects to the profiles list" do
        delete :destroy, id: profiles(:user2).id
        response.should redirect_to(profiles_url)
      end

      it "should destroy librarian" do
        delete :destroy, id: profiles(:librarian2).id
        response.should redirect_to(profiles_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user" do
        delete :destroy, id: profiles(:user2).id
      end

      it "redirects to the profiles list" do
        delete :destroy, id: profiles(:user2).id
        response.should redirect_to(profiles_url)
      end

      it "should not destroy librarian" do
        delete :destroy, id: profiles(:librarian2).id
        response.should be_forbidden
      end

      it "should not destroy admin" do
        delete :destroy, id: profiles(:admin).id
        response.should be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, id: profiles(:librarian1).id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user" do
        delete :destroy, id: profiles(:user2).id
      end

      it "should be forbidden" do
        delete :destroy, id: profiles(:user2).id
        response.should be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, id: profiles(:user1).id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user" do
        delete :destroy, id: profiles(:user2).id
      end

      it "should be forbidden" do
        delete :destroy, id: profiles(:user2).id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
