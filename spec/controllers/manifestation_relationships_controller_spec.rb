require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ManifestationRelationshipsController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    @attrs = FactoryGirl.attributes_for(:manifestation_relationship)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:manifestation_relationship)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all manifestation_relationships as @manifestation_relationships" do
        get :index
        assigns(:manifestation_relationships).should eq(ManifestationRelationship.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all manifestation_relationships as @manifestation_relationships" do
        get :index
        assigns(:manifestation_relationships).should eq(ManifestationRelationship.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all manifestation_relationships as @manifestation_relationships" do
        get :index
        assigns(:manifestation_relationships).should eq(ManifestationRelationship.all)
      end
    end

    describe "When not logged in" do
      it "assigns all manifestation_relationships as @manifestation_relationships" do
        get :index
        assigns(:manifestation_relationships).should eq(ManifestationRelationship.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :show, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :show, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :show, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :show, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        get :new
        assigns(:manifestation_relationship).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested manifestation_relationship as @manifestation_relationship" do
        get :new
        assigns(:manifestation_relationship).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested manifestation_relationship as @manifestation_relationship" do
        get :new
        assigns(:manifestation_relationship).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation_relationship as @manifestation_relationship" do
        get :new
        assigns(:manifestation_relationship).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :edit, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :edit, :id => manifestation_relationship.id
        assigns(:manifestation_relationship).should eq(manifestation_relationship)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :edit, :id => manifestation_relationship.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation_relationship as @manifestation_relationship" do
        manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
        get :edit, :id => manifestation_relationship.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:parent_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation_relationship => @attrs
          response.should redirect_to(assigns(:manifestation_relationship))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @invalid_attrs
          assigns(:manifestation_relationship).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation_relationship => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should be_valid
        end

        it "redirects to the created manifestation" do
          post :create, :manifestation_relationship => @attrs
          response.should redirect_to(assigns(:manifestation_relationship))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @invalid_attrs
          assigns(:manifestation_relationship).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :manifestation_relationship => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @invalid_attrs
          assigns(:manifestation_relationship).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship" do
          post :create, :manifestation_relationship => @invalid_attrs
          assigns(:manifestation_relationship).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
      @attrs = valid_attributes
      @invalid_attrs = {:parent_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
        end

        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should eq(@manifestation_relationship)
          response.should redirect_to(@manifestation_relationship)
        end

        it "moves its position when specified" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs, :move => 'lower'
          response.should redirect_to(manifestation_relationships_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
        end

        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should eq(@manifestation_relationship)
          response.should redirect_to(@manifestation_relationship)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
        end

        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
          assigns(:manifestation_relationship).should eq(@manifestation_relationship)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship as @manifestation_relationship" do
          put :update, :id => @manifestation_relationship.id, :manifestation_relationship => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation_relationship = FactoryGirl.create(:manifestation_relationship)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested manifestation_relationship" do
        delete :destroy, :id => @manifestation_relationship.id
      end

      it "redirects to the manifestation_relationships list" do
        delete :destroy, :id => @manifestation_relationship.id
        response.should redirect_to(manifestation_relationships_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested manifestation_relationship" do
        delete :destroy, :id => @manifestation_relationship.id
      end

      it "redirects to the manifestation_relationships list" do
        delete :destroy, :id => @manifestation_relationship.id
        response.should redirect_to(manifestation_relationships_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested manifestation_relationship" do
        delete :destroy, :id => @manifestation_relationship.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation_relationship.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation_relationship" do
        delete :destroy, :id => @manifestation_relationship.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation_relationship.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
