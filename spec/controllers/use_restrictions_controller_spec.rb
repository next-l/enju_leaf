require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe UseRestrictionsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      Factory.create(:use_restriction)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all use_restrictions as @use_restrictions" do
        get :index
        assigns(:use_restrictions).should eq(UseRestriction.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all use_restrictions as @use_restrictions" do
        get :index
        assigns(:use_restrictions).should eq(UseRestriction.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should be forbidden" do
        get :index
        assigns(:use_restrictions).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all use_restrictions as @use_restrictions" do
        get :index
        assigns(:use_restrictions).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When not logged in" do
      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "should be forbidden" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should be forbidden" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should be forbidden" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :edit, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested use_restriction as @use_restriction" do
        use_restriction = Factory.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:use_restriction)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :use_restriction => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved use_restriction as @use_restriction" do
          post :create, :use_restriction => @invalid_attrs
          assigns(:use_restriction).should_not be_valid
        end

        it "should be successful" do
          post :create, :use_restriction => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved use_restriction as @use_restriction" do
          post :create, :use_restriction => @invalid_attrs
          assigns(:use_restriction).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved use_restriction as @use_restriction" do
          post :create, :use_restriction => @invalid_attrs
          assigns(:use_restriction).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved use_restriction as @use_restriction" do
          post :create, :use_restriction => @invalid_attrs
          assigns(:use_restriction).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :use_restriction => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @use_restriction = Factory(:use_restriction)
      @attrs = Factory.attributes_for(:use_restriction)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
        end

        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
          assigns(:use_restriction).should eq(@use_restriction)
        end

        it "moves its position when specified" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs, :position => 2
          response.should redirect_to(use_restrictions_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
        end

        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
          assigns(:use_restriction).should eq(@use_restriction)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
        end

        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
          assigns(:use_restriction).should eq(@use_restriction)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @use_restriction = Factory(:use_restriction)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "redirects to the use_restrictions list" do
        delete :destroy, :id => @use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @use_restriction.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
