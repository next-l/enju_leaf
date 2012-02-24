require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe UseRestrictionsController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
     FactoryGirl.attributes_for(:use_restriction)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:use_restriction)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all use_restrictions as @use_restrictions" do
        get :index
        assigns(:use_restrictions).should eq(UseRestriction.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all use_restrictions as @use_restrictions" do
        get :index
        assigns(:use_restrictions).should eq(UseRestriction.all)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When not logged in" do
      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :show, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "should be forbidden" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should be forbidden" do
        get :new
        assigns(:use_restriction).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :edit, :id => use_restriction.id
        assigns(:use_restriction).should eq(use_restriction)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested use_restriction as @use_restriction" do
        use_restriction = FactoryGirl.create(:use_restriction)
        get :edit, :id => use_restriction.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should_not be_valid
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
      login_librarian

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should_not be_valid
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
      login_user

      describe "with valid params" do
        it "assigns a newly created use_restriction as @use_restriction" do
          post :create, :use_restriction => @attrs
          assigns(:use_restriction).should_not be_valid
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
          assigns(:use_restriction).should_not be_valid
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
      @use_restriction = FactoryGirl.create(:use_restriction)
      @attrs = valid_attributes
      @invalid_attrs = {:display_name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
        end

        it "assigns the requested use_restriction as @use_restriction" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs
          assigns(:use_restriction).should eq(@use_restriction)
        end

        it "moves its position when specified" do
          put :update, :id => @use_restriction.id, :use_restriction => @attrs, :move => 'lower'
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
      login_librarian

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
      login_user

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
      @use_restriction = FactoryGirl.create(:use_restriction)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "redirects to the use_restrictions list" do
        delete :destroy, :id => @use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested use_restriction" do
        delete :destroy, :id => @use_restriction.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @use_restriction.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
