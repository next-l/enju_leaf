require 'spec_helper'

describe ManifestationRelationshipTypesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:manifestation_relationship_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all manifestation_relationship_types as @manifestation_relationship_types" do
        get :index
        assigns(:manifestation_relationship_types).should eq(ManifestationRelationshipType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all manifestation_relationship_types as @manifestation_relationship_types" do
        get :index
        assigns(:manifestation_relationship_types).should eq(ManifestationRelationshipType.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all manifestation_relationship_types as @manifestation_relationship_types" do
        get :index
        assigns(:manifestation_relationship_types).should eq(ManifestationRelationshipType.all)
      end
    end

    describe "When not logged in" do
      it "assigns all manifestation_relationship_types as @manifestation_relationship_types" do
        get :index
        assigns(:manifestation_relationship_types).should eq(ManifestationRelationshipType.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :show, :id => manifestation_relationship_type.id
        assigns(:manifestation_relationship_type).should eq(manifestation_relationship_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :show, :id => manifestation_relationship_type.id
        assigns(:manifestation_relationship_type).should eq(manifestation_relationship_type)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :show, :id => manifestation_relationship_type.id
        assigns(:manifestation_relationship_type).should eq(manifestation_relationship_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :show, :id => manifestation_relationship_type.id
        assigns(:manifestation_relationship_type).should eq(manifestation_relationship_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        get :new
        assigns(:manifestation_relationship_type).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested manifestation_relationship_type as @manifestation_relationship_type" do
        get :new
        assigns(:manifestation_relationship_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested manifestation_relationship_type as @manifestation_relationship_type" do
        get :new
        assigns(:manifestation_relationship_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation_relationship_type as @manifestation_relationship_type" do
        get :new
        assigns(:manifestation_relationship_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :edit, :id => manifestation_relationship_type.id
        assigns(:manifestation_relationship_type).should eq(manifestation_relationship_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :edit, :id => manifestation_relationship_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :edit, :id => manifestation_relationship_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested manifestation_relationship_type as @manifestation_relationship_type" do
        manifestation_relationship_type = Factory.create(:manifestation_relationship_type)
        get :edit, :id => manifestation_relationship_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:manifestation_relationship_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :manifestation_relationship_type => @attrs
          response.should redirect_to(assigns(:manifestation_relationship_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          assigns(:manifestation_relationship_type).should_not be_valid
        end

        it "should be successful" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          assigns(:manifestation_relationship_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          assigns(:manifestation_relationship_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved manifestation_relationship_type as @manifestation_relationship_type" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          assigns(:manifestation_relationship_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :manifestation_relationship_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @manifestation_relationship_type = Factory(:manifestation_relationship_type)
      @attrs = Factory.attributes_for(:manifestation_relationship_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
        end

        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should eq(@manifestation_relationship_type)
        end

        it "moves its position when specified" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs, :position => 2
          response.should redirect_to(manifestation_relationship_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
        end

        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should eq(@manifestation_relationship_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
        end

        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
          assigns(:manifestation_relationship_type).should eq(@manifestation_relationship_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested manifestation_relationship_type as @manifestation_relationship_type" do
          put :update, :id => @manifestation_relationship_type.id, :manifestation_relationship_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @manifestation_relationship_type = Factory(:manifestation_relationship_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested manifestation_relationship_type" do
        delete :destroy, :id => @manifestation_relationship_type.id
      end

      it "redirects to the manifestation_relationship_types list" do
        delete :destroy, :id => @manifestation_relationship_type.id
        response.should redirect_to(manifestation_relationship_types_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested manifestation_relationship_type" do
        delete :destroy, :id => @manifestation_relationship_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation_relationship_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested manifestation_relationship_type" do
        delete :destroy, :id => @manifestation_relationship_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation_relationship_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested manifestation_relationship_type" do
        delete :destroy, :id => @manifestation_relationship_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @manifestation_relationship_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
