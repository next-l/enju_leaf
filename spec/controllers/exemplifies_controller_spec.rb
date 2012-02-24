require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ExemplifiesController do
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:exemplify)
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all exemplifies as @exemplifies" do
        get :index
        assigns(:exemplifies).should eq(Exemplify.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all exemplifies as @exemplifies" do
        get :index
        assigns(:exemplifies).should eq(Exemplify.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all exemplifies as @exemplifies" do
        get :index
        assigns(:exemplifies).should eq(Exemplify.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all exemplifies as @exemplifies" do
        get :index
        assigns(:exemplifies).should eq(Exemplify.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :show, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :show, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :show, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end

    describe "When not logged in" do
      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :show, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested exemplify as @exemplify" do
        get :new
        assigns(:exemplify).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested exemplify as @exemplify" do
        get :new
        assigns(:exemplify).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested exemplify as @exemplify" do
        get :new
        assigns(:exemplify).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested exemplify as @exemplify" do
        get :new
        assigns(:exemplify).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :edit, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :edit, :id => exemplify.id
        assigns(:exemplify).should eq(exemplify)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :edit, :id => exemplify.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested exemplify as @exemplify" do
        exemplify = FactoryGirl.create(:exemplify)
        get :edit, :id => exemplify.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created exemplify as @exemplify" do
          post :create, :exemplify => @attrs
          assigns(:exemplify).should be_valid
        end

        it "redirects to the created exemplify" do
          post :create, :exemplify => @attrs
          response.should redirect_to(exemplify_url(assigns(:exemplify)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved exemplify as @exemplify" do
          post :create, :exemplify => @invalid_attrs
          assigns(:exemplify).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :exemplify => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created exemplify as @exemplify" do
          post :create, :exemplify => @attrs
          assigns(:exemplify).should be_valid
        end

        it "redirects to the created exemplify" do
          post :create, :exemplify => @attrs
          response.should redirect_to(exemplify_url(assigns(:exemplify)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved exemplify as @exemplify" do
          post :create, :exemplify => @invalid_attrs
          assigns(:exemplify).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :exemplify => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created exemplify as @exemplify" do
          post :create, :exemplify => @attrs
          assigns(:exemplify).should be_valid
        end

        it "should be forbidden" do
          post :create, :exemplify => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved exemplify as @exemplify" do
          post :create, :exemplify => @invalid_attrs
          assigns(:exemplify).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :exemplify => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created exemplify as @exemplify" do
          post :create, :exemplify => @attrs
          assigns(:exemplify).should be_valid
        end

        it "should be forbidden" do
          post :create, :exemplify => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved exemplify as @exemplify" do
          post :create, :exemplify => @invalid_attrs
          assigns(:exemplify).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :exemplify => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @exemplify = FactoryGirl.create(:exemplify)
      @attrs = valid_attributes
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
        end

        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
          assigns(:exemplify).should eq(@exemplify)
        end
      end

      describe "with invalid params" do
        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
        end

        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
          assigns(:exemplify).should eq(@exemplify)
          response.should redirect_to(@exemplify)
        end
      end

      describe "with invalid params" do
        it "assigns the exemplify as @exemplify" do
          put :update, :id => @exemplify, :exemplify => @invalid_attrs
          assigns(:exemplify).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @exemplify, :exemplify => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
        end

        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
          assigns(:exemplify).should eq(@exemplify)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @exemplify.id, :exemplify => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested exemplify as @exemplify" do
          put :update, :id => @exemplify.id, :exemplify => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @exemplify = FactoryGirl.create(:exemplify)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested exemplify" do
        delete :destroy, :id => @exemplify.id
      end

      it "redirects to the exemplifies list" do
        delete :destroy, :id => @exemplify.id
        response.should redirect_to(exemplifies_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested exemplify" do
        delete :destroy, :id => @exemplify.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @exemplify.id
        response.should redirect_to(exemplifies_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested exemplify" do
        delete :destroy, :id => @exemplify.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @exemplify.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested exemplify" do
        delete :destroy, :id => @exemplify.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @exemplify.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
