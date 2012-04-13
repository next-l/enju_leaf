require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe CountriesController do
  fixtures :countries, :patron_types, :library_groups, :languages, :user_groups,
    :roles
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:country)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:country)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all countries as @countries" do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all countries as @countries" do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all countries as @countries" do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all countries as @countries" do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @country = FactoryGirl.create(:country)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested country as @country" do
        get :show, :id => @country.id
        assigns(:country).should eq(@country)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested country as @country" do
        get :show, :id => @country.id
        assigns(:country).should eq(@country)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested country as @country" do
        get :show, :id => @country.id
        assigns(:country).should eq(@country)
      end
    end

    describe "When not logged in" do
      it "assigns the requested country as @country" do
        get :show, :id => @country.id
        assigns(:country).should eq(@country)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested country as @country" do
        get :new
        assigns(:country).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested country as @country" do
        get :new
        assigns(:country).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested country as @country" do
        get :new
        assigns(:country).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested country as @country" do
        get :new
        assigns(:country).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested country as @country" do
        country = FactoryGirl.create(:country)
        get :edit, :id => country.id
        assigns(:country).should eq(country)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested country as @country" do
        country = FactoryGirl.create(:country)
        get :edit, :id => country.id
        assigns(:country).should eq(country)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested country as @country" do
        country = FactoryGirl.create(:country)
        get :edit, :id => country.id
        assigns(:country).should eq(country)
      end
    end

    describe "When not logged in" do
      it "should not assign the requested country as @country" do
        country = FactoryGirl.create(:country)
        get :edit, :id => country.id
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
        it "assigns a newly created country as @country" do
          post :create, :country => @attrs
          assigns(:country).should be_valid
        end

        it "should be forbidden" do
          post :create, :country => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved country as @country" do
          post :create, :country => @invalid_attrs
          assigns(:country).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :country => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created country as @country" do
          post :create, :country => @attrs
          assigns(:country).should be_valid
        end

        it "should be forbidden" do
          post :create, :country => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved country as @country" do
          post :create, :country => @invalid_attrs
          assigns(:country).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :country => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created country as @country" do
          post :create, :country => @attrs
          assigns(:country).should be_valid
        end

        it "should be forbidden" do
          post :create, :country => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved country as @country" do
          post :create, :country => @invalid_attrs
          assigns(:country).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :country => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created country as @country" do
          post :create, :country => @attrs
          assigns(:country).should be_valid
        end

        it "should be forbidden" do
          post :create, :country => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved country as @country" do
          post :create, :country => @invalid_attrs
          assigns(:country).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :country => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @country = FactoryGirl.create(:country)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested country" do
          put :update, :id => @country.id, :country => @attrs
        end

        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @attrs
          assigns(:country).should eq(@country)
        end

        it "moves its position when specified" do
          put :update, :id => @country.id, :country => @attrs, :move => 'lower'
          response.should redirect_to(countries_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested country" do
          put :update, :id => @country.id, :country => @attrs
        end

        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @attrs
          assigns(:country).should eq(@country)
        end

        it "moves its position when specified" do
          put :update, :id => @country.id, :country => @attrs, :move => 'lower'
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested country" do
          put :update, :id => @country.id, :country => @attrs
        end

        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @attrs
          assigns(:country).should eq(@country)
        end

        it "moves its position when specified" do
          put :update, :id => @country.id, :country => @attrs, :move => 'lower'
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested country" do
          put :update, :id => @country.id, :country => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @country.id, :country => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested country as @country" do
          put :update, :id => @country.id, :country => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @country = FactoryGirl.create(:country)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested country" do
        delete :destroy, :id => @country.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @country.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested country" do
        delete :destroy, :id => @country.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @country.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested country" do
        delete :destroy, :id => @country.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @country.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested country" do
        delete :destroy, :id => @country.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @country.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
