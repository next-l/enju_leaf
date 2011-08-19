require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe LicensesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:license)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all licenses as @licenses" do
        get :index
        assigns(:licenses).should eq(License.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all licenses as @licenses" do
        get :index
        assigns(:licenses).should eq(License.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all licenses as @licenses" do
        get :index
        assigns(:licenses).should eq(License.all)
      end
    end

    describe "When not logged in" do
      it "assigns all licenses as @licenses" do
        get :index
        assigns(:licenses).should eq(License.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :show, :id => license.id
        assigns(:license).should eq(license)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :show, :id => license.id
        assigns(:license).should eq(license)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :show, :id => license.id
        assigns(:license).should eq(license)
      end
    end

    describe "When not logged in" do
      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :show, :id => license.id
        assigns(:license).should eq(license)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested license as @license" do
        get :new
        assigns(:license).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested license as @license" do
        get :new
        assigns(:license).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested license as @license" do
        get :new
        assigns(:license).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested license as @license" do
        get :new
        assigns(:license).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :edit, :id => license.id
        assigns(:license).should eq(license)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :edit, :id => license.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :edit, :id => license.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested license as @license" do
        license = FactoryGirl.create(:license)
        get :edit, :id => license.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:license)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created license as @license" do
          post :create, :license => @attrs
          assigns(:license).should be_valid
        end

        it "should be forbidden" do
          post :create, :license => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved license as @license" do
          post :create, :license => @invalid_attrs
          assigns(:license).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :license => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created license as @license" do
          post :create, :license => @attrs
          assigns(:license).should be_valid
        end

        it "should be forbidden" do
          post :create, :license => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved license as @license" do
          post :create, :license => @invalid_attrs
          assigns(:license).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :license => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created license as @license" do
          post :create, :license => @attrs
          assigns(:license).should be_valid
        end

        it "should be forbidden" do
          post :create, :license => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved license as @license" do
          post :create, :license => @invalid_attrs
          assigns(:license).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :license => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created license as @license" do
          post :create, :license => @attrs
          assigns(:license).should be_valid
        end

        it "should be forbidden" do
          post :create, :license => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved license as @license" do
          post :create, :license => @invalid_attrs
          assigns(:license).should_not be_valid
        end

        it "should be redirect to new session url" do
          post :create, :license => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @license = FactoryGirl.create(:license)
      @attrs = FactoryGirl.attributes_for(:license)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested license" do
          put :update, :id => @license.id, :license => @attrs
        end

        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @attrs
          assigns(:license).should eq(@license)
        end

        it "moves its position when specified" do
          put :update, :id => @license.id, :license => @attrs, :position => 2
          response.should redirect_to(licenses_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested license" do
          put :update, :id => @license.id, :license => @attrs
        end

        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @attrs
          assigns(:license).should eq(@license)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested license" do
          put :update, :id => @license.id, :license => @attrs
        end

        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @attrs
          assigns(:license).should eq(@license)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested license" do
          put :update, :id => @license.id, :license => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @license.id, :license => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested license as @license" do
          put :update, :id => @license.id, :license => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @license = FactoryGirl.create(:license)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested license" do
        delete :destroy, :id => @license.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @license.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested license" do
        delete :destroy, :id => @license.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @license.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested license" do
        delete :destroy, :id => @license.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @license.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested license" do
        delete :destroy, :id => @license.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @license.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
