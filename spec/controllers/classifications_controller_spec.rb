require 'spec_helper'

describe ClassificationsController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_nil
      end

      it "should get index with query" do
        get :index, :query => '500'
        response.should be_success
        assigns(:classifications).should_not be_nil
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @classification = FactoryGirl.create(:classification)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested classification as @classification" do
        get :show, :id => @classification.id
        assigns(:classification).should eq(@classification)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested classification as @classification" do
        get :show, :id => @classification.id
        assigns(:classification).should eq(@classification)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested classification as @classification" do
        get :show, :id => @classification.id
        assigns(:classification).should eq(@classification)
      end
    end

    describe "When not logged in" do
      it "assigns the requested classification as @classification" do
        get :show, :id => @classification.id
        assigns(:classification).should eq(@classification)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should assign the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested classification as @classification" do
        classification = FactoryGirl.create(:classification)
        get :edit, :id => classification.id
        assigns(:classification).should eq(classification)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested classification as @classification" do
        classification = FactoryGirl.create(:classification)
        get :edit, :id => classification.id
        assigns(:classification).should eq(classification)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested classification as @classification" do
        classification = FactoryGirl.create(:classification)
        get :edit, :id => classification.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested classification as @classification" do
        classification = FactoryGirl.create(:classification)
        get :edit, :id => classification.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:classification)
      @invalid_attrs = {:category => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created classification as @classification" do
          post :create, :classification => @attrs
          assigns(:classification).should be_valid
        end

        it "redirects to the created classification" do
          post :create, :classification => @attrs
          response.should redirect_to(classification_url(assigns(:classification)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved classification as @classification" do
          post :create, :classification => @invalid_attrs
          assigns(:classification).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :classification => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created classification as @classification" do
          post :create, :classification => @attrs
          assigns(:classification).should be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved classification as @classification" do
          post :create, :classification => @invalid_attrs
          assigns(:classification).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created classification as @classification" do
          post :create, :classification => @attrs
          assigns(:classification).should be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved classification as @classification" do
          post :create, :classification => @invalid_attrs
          assigns(:classification).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created classification as @classification" do
          post :create, :classification => @attrs
          assigns(:classification).should be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved classification as @classification" do
          post :create, :classification => @invalid_attrs
          assigns(:classification).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :classification => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @classification = FactoryGirl.create(:classification)
      @attrs = FactoryGirl.attributes_for(:classification)
      @invalid_attrs = {:category => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested classification" do
          put :update, :id => @classification.id, :classification => @attrs
        end

        it "assigns the requested classification as @classification" do
          put :update, :id => @classification.id, :classification => @attrs
          assigns(:classification).should eq(@classification)
        end
      end

      describe "with invalid params" do
        it "assigns the requested classification as @classification" do
          put :update, :id => @classification.id, :classification => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested classification" do
          put :update, :id => @classification.id, :classification => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @classification.id, :classification => @attrs
          assigns(:classification).should eq(@classification)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "should be forbidden" do
          put :update, :id => @classification, :classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested classification" do
          put :update, :id => @classification.id, :classification => @attrs
        end

        it "assigns the requested classification as @classification" do
          put :update, :id => @classification.id, :classification => @attrs
          assigns(:classification).should eq(@classification)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested classification as @classification" do
          put :update, :id => @classification.id, :classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested classification" do
          put :update, :id => @classification.id, :classification => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @classification.id, :classification => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested classification as @classification" do
          put :update, :id => @classification.id, :classification => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @classification = FactoryGirl.create(:classification)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested classification" do
        delete :destroy, :id => @classification.id
      end

      it "redirects to the classifications list" do
        delete :destroy, :id => @classification.id
        response.should redirect_to(classifications_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested classification" do
        delete :destroy, :id => @classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @classification.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested classification" do
        delete :destroy, :id => @classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @classification.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested classification" do
        delete :destroy, :id => @classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @classification.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
