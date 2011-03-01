require 'spec_helper'

describe EventCategoriesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:event_category)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.all)
      end
    end

    describe "When not logged in" do
      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :show, :id => event_category.id
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :show, :id => event_category.id
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :show, :id => event_category.id
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When not logged in" do
      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :show, :id => event_category.id
        assigns(:event_category).should eq(event_category)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :edit, :id => event_category.id
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :edit, :id => event_category.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :edit, :id => event_category.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_category as @event_category" do
        event_category = Factory.create(:event_category)
        get :edit, :id => event_category.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:event_category)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, :event_category => @attrs
          assigns(:event_category).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :event_category => @attrs
          response.should redirect_to(assigns(:event_category))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, :event_category => @invalid_attrs
          assigns(:event_category).should_not be_valid
        end

        it "should be successful" do
          post :create, :event_category => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, :event_category => @attrs
          assigns(:event_category).should be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, :event_category => @invalid_attrs
          assigns(:event_category).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, :event_category => @attrs
          assigns(:event_category).should be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, :event_category => @invalid_attrs
          assigns(:event_category).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, :event_category => @attrs
          assigns(:event_category).should be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, :event_category => @invalid_attrs
          assigns(:event_category).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event_category => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @event_category = Factory(:event_category)
      @attrs = Factory.attributes_for(:event_category)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
        end

        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
          assigns(:event_category).should eq(@event_category)
        end

        it "moves its position when specified" do
          put :update, :id => @event_category.id, :event_category => @attrs, :position => 2
          response.should redirect_to(event_categories_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
        end

        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
          assigns(:event_category).should eq(@event_category)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
        end

        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
          assigns(:event_category).should eq(@event_category)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, :id => @event_category.id, :event_category => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @event_category.id, :event_category => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, :id => @event_category.id, :event_category => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event_category = Factory(:event_category)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested event_category" do
        delete :destroy, :id => @event_category.id
      end

      it "redirects to the event_categories list" do
        delete :destroy, :id => @event_category.id
        response.should redirect_to(event_categories_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested event_category" do
        delete :destroy, :id => @event_category.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event_category.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested event_category" do
        delete :destroy, :id => @event_category.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event_category.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event_category" do
        delete :destroy, :id => @event_category.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event_category.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
