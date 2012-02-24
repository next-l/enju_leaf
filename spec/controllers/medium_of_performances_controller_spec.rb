require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe MediumOfPerformancesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:medium_of_performance)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:medium_of_performance)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all medium_of_performances as @medium_of_performances" do
        get :index
        assigns(:medium_of_performances).should eq(MediumOfPerformance.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all medium_of_performances as @medium_of_performances" do
        get :index
        assigns(:medium_of_performances).should eq(MediumOfPerformance.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all medium_of_performances as @medium_of_performances" do
        get :index
        assigns(:medium_of_performances).should eq(MediumOfPerformance.all)
      end
    end

    describe "When not logged in" do
      it "assigns all medium_of_performances as @medium_of_performances" do
        get :index
        assigns(:medium_of_performances).should eq(MediumOfPerformance.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :show, :id => medium_of_performance.id
        assigns(:medium_of_performance).should eq(medium_of_performance)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :show, :id => medium_of_performance.id
        assigns(:medium_of_performance).should eq(medium_of_performance)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :show, :id => medium_of_performance.id
        assigns(:medium_of_performance).should eq(medium_of_performance)
      end
    end

    describe "When not logged in" do
      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :show, :id => medium_of_performance.id
        assigns(:medium_of_performance).should eq(medium_of_performance)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        get :new
        assigns(:medium_of_performance).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested medium_of_performance as @medium_of_performance" do
        get :new
        assigns(:medium_of_performance).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested medium_of_performance as @medium_of_performance" do
        get :new
        assigns(:medium_of_performance).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested medium_of_performance as @medium_of_performance" do
        get :new
        assigns(:medium_of_performance).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :edit, :id => medium_of_performance.id
        assigns(:medium_of_performance).should eq(medium_of_performance)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :edit, :id => medium_of_performance.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :edit, :id => medium_of_performance.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested medium_of_performance as @medium_of_performance" do
        medium_of_performance = FactoryGirl.create(:medium_of_performance)
        get :edit, :id => medium_of_performance.id
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
        it "assigns a newly created medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @invalid_attrs
          assigns(:medium_of_performance).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @invalid_attrs
          assigns(:medium_of_performance).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @invalid_attrs
          assigns(:medium_of_performance).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved medium_of_performance as @medium_of_performance" do
          post :create, :medium_of_performance => @invalid_attrs
          assigns(:medium_of_performance).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :medium_of_performance => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @medium_of_performance = FactoryGirl.create(:medium_of_performance)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
        end

        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should eq(@medium_of_performance)
        end

        it "moves its position when specified" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs, :move => 'lower'
          response.should redirect_to(medium_of_performances_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
        end

        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should eq(@medium_of_performance)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
        end

        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
          assigns(:medium_of_performance).should eq(@medium_of_performance)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested medium_of_performance as @medium_of_performance" do
          put :update, :id => @medium_of_performance.id, :medium_of_performance => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @medium_of_performance = FactoryGirl.create(:medium_of_performance)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested medium_of_performance" do
        delete :destroy, :id => @medium_of_performance.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @medium_of_performance.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested medium_of_performance" do
        delete :destroy, :id => @medium_of_performance.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @medium_of_performance.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested medium_of_performance" do
        delete :destroy, :id => @medium_of_performance.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @medium_of_performance.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested medium_of_performance" do
        delete :destroy, :id => @medium_of_performance.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @medium_of_performance.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
