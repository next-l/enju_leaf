require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe LendingPoliciesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:lending_policy)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:lending_policy)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all lending_policies as @lending_policies" do
        get :index
        assigns(:lending_policies).should eq(LendingPolicy.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all lending_policies as @lending_policies" do
        get :index
        assigns(:lending_policies).should eq(LendingPolicy.all)
      end
    end

    describe "When logged in as User" do
      login_user

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
    before(:each) do
      @lending_policy = FactoryGirl.create(:lending_policy)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested lending_policy as @lending_policy" do
        get :show, :id => @lending_policy.id
        assigns(:lending_policy).should eq(@lending_policy)
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested lending_policy as @lending_policy" do
        get :show, :id => @lending_policy.id
        assigns(:lending_policy).should eq(@lending_policy)
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should be forbidden" do
        get :show, :id => @lending_policy.id
        assigns(:lending_policy).should eq(@lending_policy)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected to new_user_session_url" do
        get :show, :id => @lending_policy.id
        assigns(:lending_policy).should eq(@lending_policy)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested lending_policy as @lending_policy" do
        get :new
        assigns(:lending_policy).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        assigns(:lending_policy).should eq(lending_policy)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested lending_policy as @lending_policy" do
        lending_policy = FactoryGirl.create(:lending_policy)
        get :edit, :id => lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
      @attrs = valid_attributes
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

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

    describe "When logged in as Librarian" do
      login_librarian

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
      login_user

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
      @attrs = valid_attributes
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

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
      login_librarian

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
      login_user

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
      login_admin

      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "redirects to the lending_policies list" do
        delete :destroy, :id => @lending_policy.id
        response.should redirect_to(lending_policies_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested lending_policy" do
        delete :destroy, :id => @lending_policy.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @lending_policy.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
