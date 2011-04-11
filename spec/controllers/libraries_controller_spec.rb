require 'spec_helper'

describe LibrariesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all libraries as @libraries" do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all libraries as @libraries" do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested library as @library" do
        get :show, :id => 1
        assigns(:library).should eq(Library.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested library as @library" do
        get :show, :id => 1
        assigns(:library).should eq(Library.find(1))
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested library as @library" do
        get :new
        assigns(:library).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested library as @library" do
        get :new
        assigns(:library).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested library as @library" do
        get :new
        assigns(:library).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested library as @library" do
        get :new
        assigns(:library).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested library as @library" do
        library = Factory.create(:library)
        get :edit, :id => library.id
        assigns(:library).should eq(library)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested library as @library" do
        library = Factory.create(:library)
        get :edit, :id => library.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested library as @library" do
        library = Factory.create(:library)
        get :edit, :id => library.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested library as @library" do
        library = Factory.create(:library)
        get :edit, :id => library.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:library)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created library as @library" do
          post :create, :library => @attrs
          assigns(:library).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :library => @attrs
          response.should redirect_to(assigns(:library))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved library as @library" do
          post :create, :library => @invalid_attrs
          assigns(:library).should_not be_valid
        end

        it "should be successful" do
          post :create, :library => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created library as @library" do
          post :create, :library => @attrs
          assigns(:library).should be_valid
        end

        it "should be forbidden" do
          post :create, :library => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved library as @library" do
          post :create, :library => @invalid_attrs
          assigns(:library).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :library => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created library as @library" do
          post :create, :library => @attrs
          assigns(:library).should be_valid
        end

        it "should be forbidden" do
          post :create, :library => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved library as @library" do
          post :create, :library => @invalid_attrs
          assigns(:library).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :library => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created library as @library" do
          post :create, :library => @attrs
          assigns(:library).should be_valid
        end

        it "should be forbidden" do
          post :create, :library => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved library as @library" do
          post :create, :library => @invalid_attrs
          assigns(:library).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :library => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end
end
