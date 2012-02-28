require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe BookstoresController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:bookstore)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:bookstore)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all bookstores as @bookstores" do
        get :index
        assigns(:bookstores).should eq(Bookstore.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all bookstores as @bookstores" do
        get :index
        assigns(:bookstores).should eq(Bookstore.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all bookstores as @bookstores" do
        get :index
        assigns(:bookstores).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all bookstores as @bookstores" do
        get :index
        assigns(:bookstores).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @bookstore = FactoryGirl.create(:bookstore)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookstore as @bookstore" do
        get :show, :id => @bookstore.id
        assigns(:bookstore).should eq(@bookstore)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookstore as @bookstore" do
        get :show, :id => @bookstore.id
        assigns(:bookstore).should eq(@bookstore)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested bookstore as @bookstore" do
        get :show, :id => @bookstore.id
        assigns(:bookstore).should eq(@bookstore)
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookstore as @bookstore" do
        get :show, :id => @bookstore.id
        assigns(:bookstore).should eq(@bookstore)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookstore as @bookstore" do
        get :new
        assigns(:bookstore).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested bookstore as @bookstore" do
        get :new
        assigns(:bookstore).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested bookstore as @bookstore" do
        get :new
        assigns(:bookstore).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookstore as @bookstore" do
        get :new
        assigns(:bookstore).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @bookstore = FactoryGirl.create(:bookstore)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookstore as @bookstore" do
        get :edit, :id => @bookstore.id
        assigns(:bookstore).should eq(@bookstore)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookstore as @bookstore" do
        get :edit, :id => @bookstore.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested bookstore as @bookstore" do
        get :edit, :id => @bookstore.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookstore as @bookstore" do
        get :edit, :id => @bookstore.id
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
        it "assigns a newly created bookstore as @bookstore" do
          post :create, :bookstore => @attrs
          assigns(:bookstore).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :bookstore => @attrs
          response.should redirect_to(assigns(:bookstore))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookstore as @bookstore" do
          post :create, :bookstore => @invalid_attrs
          assigns(:bookstore).should_not be_valid
        end

        it "should be successful" do
          post :create, :bookstore => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created bookstore as @bookstore" do
          post :create, :bookstore => @attrs
          assigns(:bookstore).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookstore as @bookstore" do
          post :create, :bookstore => @invalid_attrs
          assigns(:bookstore).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created bookstore as @bookstore" do
          post :create, :bookstore => @attrs
          assigns(:bookstore).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookstore as @bookstore" do
          post :create, :bookstore => @invalid_attrs
          assigns(:bookstore).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookstore as @bookstore" do
          post :create, :bookstore => @attrs
          assigns(:bookstore).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookstore as @bookstore" do
          post :create, :bookstore => @invalid_attrs
          assigns(:bookstore).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookstore => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookstore = FactoryGirl.create(:bookstore)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
        end

        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
          assigns(:bookstore).should eq(@bookstore)
        end

        it "moves its position when specified" do
          put :update, :id => @bookstore.id, :bookstore => @attrs, :move => 'lower'
          response.should redirect_to(bookstores_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
        end

        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
          assigns(:bookstore).should eq(@bookstore)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
        end

        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
          assigns(:bookstore).should eq(@bookstore)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookstore.id, :bookstore => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookstore as @bookstore" do
          put :update, :id => @bookstore.id, :bookstore => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @bookstore = FactoryGirl.create(:bookstore)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested bookstore" do
        delete :destroy, :id => @bookstore.id
      end

      it "redirects to the bookstores list" do
        delete :destroy, :id => @bookstore.id
        response.should redirect_to(bookstores_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested bookstore" do
        delete :destroy, :id => @bookstore.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookstore.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested bookstore" do
        delete :destroy, :id => @bookstore.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookstore.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookstore" do
        delete :destroy, :id => @bookstore.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookstore.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
