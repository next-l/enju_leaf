require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe CirculationStatusesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:circulation_status)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all circulation_statuses as @circulation_statuses" do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all circulation_statuses as @circulation_statuses" do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all circulation_statuses as @circulation_statuses" do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.all)
      end
    end

    describe "When not logged in" do
      it "assigns all circulation_statuses as @circulation_statuses" do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :show, :id => circulation_status.id
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :show, :id => circulation_status.id
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :show, :id => circulation_status.id
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe "When not logged in" do
      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :show, :id => circulation_status.id
        assigns(:circulation_status).should eq(circulation_status)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "should be forbidden" do
        get :new
        assigns(:circulation_status).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should be forbidden" do
        get :new
        assigns(:circulation_status).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should be forbidden" do
        get :new
        assigns(:circulation_status).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected" do
        get :new
        assigns(:circulation_status).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :edit, :id => circulation_status.id
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :edit, :id => circulation_status.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :edit, :id => circulation_status.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested circulation_status as @circulation_status" do
        circulation_status = FactoryGirl.create(:circulation_status)
        get :edit, :id => circulation_status.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:circulation_status)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created circulation_status as @circulation_status" do
          post :create, :circulation_status => @attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "redirects to the created patron" do
          post :create, :circulation_status => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved circulation_status as @circulation_status" do
          post :create, :circulation_status => @invalid_attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be successful" do
          post :create, :circulation_status => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created circulation_status as @circulation_status" do
          post :create, :circulation_status => @attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved circulation_status as @circulation_status" do
          post :create, :circulation_status => @invalid_attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created circulation_status as @circulation_status" do
          post :create, :circulation_status => @attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved circulation_status as @circulation_status" do
          post :create, :circulation_status => @invalid_attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created circulation_status as @circulation_status" do
          post :create, :circulation_status => @attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved circulation_status as @circulation_status" do
          post :create, :circulation_status => @invalid_attrs
          assigns(:circulation_status).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :circulation_status => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @circulation_status = FactoryGirl.create(:circulation_status)
      @attrs = FactoryGirl.attributes_for(:circulation_status)
      @invalid_attrs = {:display_name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
        end

        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
          assigns(:circulation_status).should eq(@circulation_status)
        end

        it "moves its position when specified" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs, :position => 2
          response.should redirect_to(circulation_statuses_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
        end

        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
          assigns(:circulation_status).should eq(@circulation_status)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
        end

        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
          assigns(:circulation_status).should eq(@circulation_status)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @circulation_status.id, :circulation_status => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested circulation_status as @circulation_status" do
          put :update, :id => @circulation_status.id, :circulation_status => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @circulation_status = FactoryGirl.create(:circulation_status)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested circulation_status" do
        delete :destroy, :id => @circulation_status.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @circulation_status.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested circulation_status" do
        delete :destroy, :id => @circulation_status.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @circulation_status.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested circulation_status" do
        delete :destroy, :id => @circulation_status.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @circulation_status.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested circulation_status" do
        delete :destroy, :id => @circulation_status.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @circulation_status.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
