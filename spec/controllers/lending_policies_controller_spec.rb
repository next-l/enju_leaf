require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe LendingPoliciesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:lending_policy)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all lending_policies as @lending_policies" do
        get :index
        assigns(:lending_policies).should eq(LendingPolicy.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all lending_policies as @lending_policies" do
        get :index
        assigns(:lending_policies).should eq(LendingPolicy.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns empty as @lending_policies" do
        get :index
        assigns(:lending_policies).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns empty lending_policies as @lending_policies" do
        get :index
        assigns(:lending_policies).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :show, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :show, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :show, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end

    describe "When not logged in" do
      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :show, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:lending_policy)
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created lending_policy as @lending_policy" do
          post :create, :lending_policy => @attrs
          assigns(:lending_policy).should be_valid
        end

        it "redirects to the created lending_policy" do
          post :create, :lending_policy => @attrs
          response.should redirect_to(lending_policy_url(assigns(:lending_policy)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved lending_policy as @lending_policy" do
          post :create, :lending_policy => @invalid_attrs
          assigns(:lending_policy).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :lending_policy => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created lending_policy as @lending_policy" do
          post :create, :lending_policy => @attrs
          assigns(:lending_policy).should be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved lending_policy as @lending_policy" do
          post :create, :lending_policy => @invalid_attrs
          assigns(:lending_policy).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created lending_policy as @lending_policy" do
          post :create, :lending_policy => @attrs
          assigns(:lending_policy).should be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved lending_policy as @lending_policy" do
          post :create, :lending_policy => @invalid_attrs
          assigns(:lending_policy).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created lending_policy as @lending_policy" do
          post :create, :lending_policy => @attrs
          assigns(:lending_policy).should be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved lending_policy as @lending_policy" do
          post :create, :lending_policy => @invalid_attrs
          assigns(:lending_policy).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :lending_policy => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @lending_policy = FactoryGirl.create(:lending_policy)
      @attrs = FactoryGirl.attributes_for(:lending_policy)
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
        end

        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
          assigns(:lending_policy).should eq(@lending_policy)
        end
      end

      describe "with invalid params" do
        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
        end

        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
          assigns(:lending_policy).should eq(@lending_policy)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
        end

        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
          assigns(:lending_policy).should eq(@lending_policy)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @lending_policy.id, :lending_policy => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested lending_policy as @lending_policy" do
          put :update, :id => @lending_policy.id, :lending_policy => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @lending_policy = FactoryGirl.create(:lending_policy)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "redirects to the lending_policies list" do
        delete :destroy, :id => @lending_policy.id
        response.should redirect_to(lending_policies_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @lending_policy.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
