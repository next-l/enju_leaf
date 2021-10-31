require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe EventCategoriesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:event_category)
  end

  describe "GET index" do
    before(:each) do
      FactoryBot.create(:event_category)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.order(:position))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.order(:position))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.order(:position))
      end
    end

    describe "When not logged in" do
      it "assigns all event_categories as @event_categories" do
        get :index
        assigns(:event_categories).should eq(EventCategory.order(:position))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :show, params: { id: event_category.id }
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :show, params: { id: event_category.id }
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :show, params: { id: event_category.id }
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When not logged in" do
      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :show, params: { id: event_category.id }
        assigns(:event_category).should eq(event_category)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should_not be_valid
        response.should be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should be_nil
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_category as @event_category" do
        get :new
        assigns(:event_category).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :edit, params: { id: event_category.id }
        assigns(:event_category).should eq(event_category)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :edit, params: { id: event_category.id }
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :edit, params: { id: event_category.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_category as @event_category" do
        event_category = FactoryBot.create(:event_category)
        get :edit, params: { id: event_category.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, params: { event_category: @attrs }
          assigns(:event_category).should be_valid
        end

        it "redirects to the created patron" do
          post :create, params: { event_category: @attrs }
          response.should redirect_to(assigns(:event_category))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, params: { event_category: @invalid_attrs }
          assigns(:event_category).should_not be_valid
        end

        it "should be successful" do
          post :create, params: { event_category: @invalid_attrs }
          response.should be_successful
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, params: { event_category: @attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, params: { event_category: @invalid_attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, params: { event_category: @attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, params: { event_category: @invalid_attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created event_category as @event_category" do
          post :create, params: { event_category: @attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event_category as @event_category" do
          post :create, params: { event_category: @invalid_attrs }
          assigns(:event_category).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event_category: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @event_category = FactoryBot.create(:event_category)
      @attrs = valid_attributes
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
        end

        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
          assigns(:event_category).should eq(@event_category)
        end

        it "moves its position when specified" do
          put :update, params: { id: @event_category.id, event_category: @attrs, move: 'lower' }
          response.should redirect_to(event_categories_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
        end

        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
          assigns(:event_category).should eq(@event_category)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
        end

        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
          assigns(:event_category).should eq(@event_category)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested event_category" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @event_category.id, event_category: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event_category as @event_category" do
          put :update, params: { id: @event_category.id, event_category: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event_category = FactoryBot.create(:event_category)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested event_category" do
        delete :destroy, params: { id: @event_category.id }
      end

      it "redirects to the event_categories list" do
        delete :destroy, params: { id: @event_category.id }
        response.should redirect_to(event_categories_url)
      end

      it "should not destroy event_category that has events" do
        event_category = EventCategory.first
        delete :destroy, params: { id: event_category.id }
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested event_category" do
        delete :destroy, params: { id: @event_category.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event_category.id }
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested event_category" do
        delete :destroy, params: { id: @event_category.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event_category.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event_category" do
        delete :destroy, params: { id: @event_category.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event_category.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
