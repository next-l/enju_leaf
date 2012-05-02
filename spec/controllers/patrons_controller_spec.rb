require 'spec_helper'

describe PatronsController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:patron)
  end

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end

      it "should get index with patron_id" do
        get :index, :patron_id => 1
        response.should be_success
        assigns(:patron).should eq Patron.find(1)
        assigns(:patrons).should eq assigns(:patron).derived_patrons.where('required_role_id >= 1').page(1)
      end

      it "should get index with query" do
        get :index, :query => 'Librarian1'
        assigns(:patrons).should_not be_empty
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end

      it "assigns all patrons as @patrons in rss format" do
        get :index, :format => :rss
        assigns(:patrons).should_not be_empty
      end

      it "assigns all patrons as @patrons in atom format" do
        get :index, :format => :atom
        assigns(:patrons).should_not be_empty
      end

      it "should get index with patron_id" do
        get :index, :patron_id => 1
        response.should be_success
        assigns(:patron).should eq Patron.find(1)
        assigns(:patrons).should eq assigns(:patron).derived_patrons.where(:required_role_id => 1).page(1)
      end

      it "should get index with manifestation_id" do
        get :index, :manifestation_id => 1
        assigns(:manifestation).should eq Manifestation.find(1)
        assigns(:patrons).should eq assigns(:manifestation).publishers.where(:required_role_id => 1).page(1)
      end

      it "should get index with query" do
        get :index, :query => 'Librarian1'
        assigns(:patrons).should be_empty
        response.should be_success
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end

      it "should show patron when required_role is user" do
        get :show, :id => users(:user2).patron.id
        assigns(:patron).should eq(users(:user2).patron)
        response.should be_success
      end

      it "should show_ atron when required_role is librarian" do
        get :show, :id => users(:user1).patron.id
        assigns(:patron).should eq(users(:user1).patron)
        response.should be_success
      end

      it "should not show patron who does not create a work" do
        get :show, :id => 3, :work_id => 3
        response.should be_missing
      end

      it "should not show patron who does not produce a manifestation" do
        get :show, :id => 4, :manifestation_id => 4
        response.should be_missing
      end

      it "should not show patron when required_role is 'Administrator'" do
        sign_in users(:librarian2)
        get :show, :id => users(:librarian1).patron.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end

      it "should show user" do
        get :show, :id => users(:user2).patron
        assigns(:patron).required_role.name.should eq 'User'
        response.should be_success
      end

      it "should not show patron when required_role is 'Librarian'" do
        sign_in users(:user2)
        get :show, :id => users(:user1).patron.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end

      it "should show patron with work" do
        get :show, :id => 1, :work_id => 1
        assigns(:patron).should eq assigns(:work).creators.first
      end

      it "should show patron with manifestation" do
        get :show, :id => 1, :manifestation_id => 1
        assigns(:patron).should eq assigns(:manifestation).publishers.first
      end

      it "should not show patron when required_role is 'User'" do
        get :show, :id => 5
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        assigns(:patron).should eq(patron)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        assigns(:patron).should eq(patron)
      end

      it "should edit patron when its required_role is 'User'" do
        get :edit, :id => users(:user2).patron.id
        response.should be_success
      end

      it "should edit patron when its required_role is 'Librarian'" do
        get :edit, :id => users(:user1).patron.id
        response.should be_success
      end
  
      it "should edit admin" do
        get :edit, :id => users(:admin).patron.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        response.should be_forbidden
      end

      it "should edit myself" do
        get :edit, :id => users(:user1).patron
        response.should be_success
      end

      it "should not edit other user's patron profile" do
        get :edit, :id => users(:user2).patron
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = FactoryGirl.attributes_for(:patron, :full_name => '')
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron => @attrs
          response.should redirect_to(patron_url(assigns(:patron)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron => @attrs
          response.should redirect_to(patron_url(assigns(:patron)))
        end

        it "should create a relationship if work_id is set" do
          post :create, :patron => @attrs, :work_id => 1
          response.should redirect_to(patron_url(assigns(:patron)))
          assigns(:patron).works.should eq [Manifestation.find(1)]
        end

        it "should create a relationship if manifestation_id is set" do
          post :create, :patron => @attrs, :manifestation_id => 1
          response.should redirect_to(patron_url(assigns(:patron)))
          assigns(:patron).manifestations.should eq [Manifestation.find(1)]
        end

        it "should create a relationship if item_id is set" do
          post :create, :patron => @attrs, :item_id => 1
          response.should redirect_to(patron_url(assigns(:patron)))
          assigns(:patron).items.should eq [Item.find(1)]
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron => @invalid_attrs
          response.should render_template("new")
        end
      end

      # TODO: full_name以外での判断
      it "should create patron without full_name" do
        post :create, :patron => { :first_name => 'test' }
        response.should redirect_to patron_url(assigns(:patron))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @invalid_attrs
          response.should be_forbidden
        end
      end

      it "should not create patron myself" do
        post :create, :patron => { :full_name => 'test', :user_username => users(:user1).username }
        assigns(:patron).should be_valid
        response.should be_forbidden
      end

      it "should not create other patron" do
        post :create, :patron => { :full_name => 'test', :user_id => users(:user2).username }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
      @attrs = valid_attributes
      @invalid_attrs = FactoryGirl.attributes_for(:patron, :full_name => '')
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
          response.should redirect_to(@patron)
        end
      end

      describe "with invalid params" do
        it "assigns the patron as @patron" do
          put :update, :id => @patron, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @patron, :patron => @invalid_attrs
          response.should render_template("edit")
        end
      end

      it "should update other patron" do
        put :update, :id => users(:user2).patron.id, :patron => { :full_name => 'test' }
        response.should redirect_to patron_url(assigns(:patron))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should be_forbidden
        end
      end

      it "should update myself" do
        put :update, :id => users(:user1).patron.id, :patron => { :full_name => 'test' }
        assigns(:patron).should be_valid
        response.should redirect_to patron_url(assigns(:patron))
      end
  
      it "should not update myself without name" do
        put :update, :id => users(:user1).patron.id, :patron => { :first_name => '', :last_name => '', :full_name => '' }
        assigns(:patron).should_not be_valid
        response.should be_success
      end
  
      it "should not update other patron" do
        put :update, :id => users(:user2).patron.id, :patron => { :full_name => 'test' }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @patron.id, :patron => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "redirects to the patrons list" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(patrons_url)
      end

      it "should not destroy librarian who has items checked out" do
        delete :destroy, :id => users(:librarian1).patron
        response.should be_forbidden
      end

      it "should destroy librarian who does not have items checked out" do
        delete :destroy, :id => users(:librarian2).patron
        response.should redirect_to patrons_url
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "redirects to the patrons list" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(patrons_url)
      end

      it "should not destroy librarian" do
        delete :destroy, :id => users(:librarian2).patron.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron.id
        response.should be_forbidden
      end

      it "should not destroy patron" do
        delete :destroy, :id => users(:user1).patron
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
