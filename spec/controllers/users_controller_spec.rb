require 'spec_helper'

describe UsersController do
  fixtures :all

  describe "GET index", :solr => true do
		before do
			User.reindex
		end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all users as @users" do
        get :index
        assigns(:users).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all users as @users" do
        get :index
        assigns(:users).should_not be_nil
      end

      it "should get index with query" do
        get :index, :query => 'user1'
        response.should be_success
        assigns(:users).should_not be_empty
      end

      it "should get sorted index" do
        get :index, :query => 'user1', :sort_by => 'username', :order => 'desc'
        response.should be_success
        assigns(:users).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all users as @users" do
        get :index
        assigns(:users).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all users as @users" do
        get :index
        assigns(:users).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should eq(User.find('admin'))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user as @user" do
        get :show, :id => users(:librarian1).username
        assigns(:user).should eq(users(:librarian1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user as @user" do
        get :show, :id => users(:user1).username
        assigns(:user).should eq(users(:user1))
      end

      it "should redirect to my user account" do
        get :show, :id => users(:user1).username
        assert_redirected_to my_account_url
      end

      it "should show other user's account" do
        get :show, :id => users(:admin).username
        assigns(:user).should eq(users(:admin))
        response.should be_success
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should eq(User.find('admin'))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should be_forbidden
      end

      it "should edit myself" do
        get :edit, :id => users(:user1).username
        response.should redirect_to edit_my_account_url
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:user)
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created user as @user" do
          post :create, :user => @attrs
          assigns(:user).should be_valid
        end

        it "redirects to the created user" do
          post :create, :user => @attrs
          response.should redirect_to(user_url(assigns(:user)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @user" do
          post :create, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created user as @user" do
          post :create, :user => @attrs
          assigns(:user).should be_valid
        end

        it "redirects to the created user" do
          post :create, :user => @attrs
          response.should redirect_to(user_url(assigns(:user)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @user" do
          post :create, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user => @invalid_attrs
          response.should render_template("new")
        end
      end

      it "should not create user without username" do
        post :create, :user => { :username => '' }
        assigns(:user).should_not be_valid
        response.should be_success
      end

      it "should create user" do
        post :create, :user => { :username => 'test10' }
        assigns(:user).should be_valid
        response.should redirect_to user_url(assigns(:user))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not create user" do
        post :create, :user => { :username => 'test10' }
        assigns(:user).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not create user" do
        post :create, :user => { :username => 'test10' }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @user = users(:user1)
      @attrs = {:email => 'newaddress@example.jp', :locale => 'en'}
      @invalid_attrs = {:email => 'invalid'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(@user)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          assigns(:user).should eq(@user)
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @user, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end

      it "should update other user's role" do
        put :update, :id => users(:user1).username, :user => {:user_has_role_attributes => {:role_id => 4}, :locale => 'en'}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).reload
        assigns(:user).role.should eq Role.find_by_name('Administrator')
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(@user)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @user" do
          put :update, :id => @user, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @user, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end

      it "should update other user" do
        put :update, :id => users(:user1).username, :user => {:user_number => '00003', :locale => 'en'}
        response.should redirect_to user_url(assigns(:user))
      end

      it "should update other user's user_group" do
        put :update, :id => users(:user1).username, :user => {:user_group_id => 3, :locale => 'en'}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).user_group_id.should eq 3
      end

      it "should update other user's note" do
        put :update, :id => users(:user1).username, :user => {:note => 'test', :locale => 'en'}
        response.should redirect_to user_url(assigns(:user))
        assert_equal assigns(:user).note, 'test'
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should be_valid
          response.should redirect_to user_url(assigns(:user))
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          assigns(:user).should_not be_valid
          response.should be_success
        end
      end

      it "should update myself" do
        put :update, :id => users(:user1).username, :user => { }
        response.should redirect_to user_url(assigns(:user))
      end

      it "should not update my role" do
        put :update, :id => users(:user1).username, :user => {:user_has_role_attributes => {:role_id => 4}}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).role.should_not eq Role.find_by_name('Administrator')
      end

      it "should not update my user_group" do
        put :update, :id => users(:user1).username, :user => {:user_group_id => 3}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).user_group.id.should eq 1
      end

      it "should not update my note" do
        put :update, :id => users(:user1).username, :user => {:note => 'test'}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).note.should be_nil
      end

      it "should update my keyword_list" do
        put :update, :id => users(:user1).username, :user => {:keyword_list => 'test'}
        response.should redirect_to user_url(assigns(:user))
        assigns(:user).keyword_list.should eq 'test'
        assigns(:user).role.name.should eq 'User'
      end

      it "should not update other user" do
        put :update, :id => users(:user2).username, :user => { }
        assigns(:user).should be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @user.id, :user => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested user" do
        delete :destroy, :id => users(:user2).username
      end

      it "redirects to the users list" do
        delete :destroy, :id => users(:user2).username
        response.should redirect_to(users_url)
      end

      it "should destroy librarian" do
        delete :destroy, :id => users(:librarian2).username
        response.should redirect_to(users_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user" do
        delete :destroy, :id => users(:user2).username
      end

      it "redirects to the users list" do
        delete :destroy, :id => users(:user2).username
        response.should redirect_to(users_url)
      end

      it "should not destroy librarian" do
        delete :destroy, :id => users(:librarian2).username
        response.should be_forbidden
      end

      it "should not destroy admin" do
        delete :destroy, :id => users(:admin).username
        response.should be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, :id => users(:librarian1).username
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user" do
        delete :destroy, :id => users(:user2).username
      end

      it "should be forbidden" do
        delete :destroy, :id => users(:user2).username
        response.should be_forbidden
      end

      it "should not destroy myself" do
        delete :destroy, :id => users(:user1).username
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user" do
        delete :destroy, :id => users(:user2).username
      end

      it "should be forbidden" do
        delete :destroy, :id => users(:user2).username
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
