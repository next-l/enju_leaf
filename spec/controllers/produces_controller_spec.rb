require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ProducesController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all produces as @produces" do
        get :index
        assigns(:produces).should eq(Produce.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all produces as @produces" do
        get :index
        assigns(:produces).should eq(Produce.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all produces as @produces" do
        get :index
        assigns(:produces).should eq(Produce.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all produces as @produces" do
        get :index
        assigns(:produces).should eq(Produce.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :show, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :show, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :show, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end

    describe "When not logged in" do
      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :show, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested produce as @produce" do
        get :new
        assigns(:produce).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested produce as @produce" do
        get :new
        assigns(:produce).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested produce as @produce" do
        get :new
        assigns(:produce).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested produce as @produce" do
        get :new
        assigns(:produce).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :edit, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :edit, :id => produce.id
        assigns(:produce).should eq(produce)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :edit, :id => produce.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested produce as @produce" do
        produce = FactoryGirl.create(:produce)
        get :edit, :id => produce.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:produce)
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created produce as @produce" do
          post :create, :produce => @attrs
          assigns(:produce).should be_valid
        end

        it "redirects to the created produce" do
          post :create, :produce => @attrs
          response.should redirect_to(produce_url(assigns(:produce)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved produce as @produce" do
          post :create, :produce => @invalid_attrs
          assigns(:produce).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :produce => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created produce as @produce" do
          post :create, :produce => @attrs
          assigns(:produce).should be_valid
        end

        it "redirects to the created produce" do
          post :create, :produce => @attrs
          response.should redirect_to(produce_url(assigns(:produce)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved produce as @produce" do
          post :create, :produce => @invalid_attrs
          assigns(:produce).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :produce => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created produce as @produce" do
          post :create, :produce => @attrs
          assigns(:produce).should be_valid
        end

        it "should be forbidden" do
          post :create, :produce => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved produce as @produce" do
          post :create, :produce => @invalid_attrs
          assigns(:produce).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :produce => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created produce as @produce" do
          post :create, :produce => @attrs
          assigns(:produce).should be_valid
        end

        it "should be forbidden" do
          post :create, :produce => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved produce as @produce" do
          post :create, :produce => @invalid_attrs
          assigns(:produce).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :produce => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @produce = FactoryGirl.create(:produce)
      @attrs = FactoryGirl.attributes_for(:produce)
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested produce" do
          put :update, :id => @produce.id, :produce => @attrs
        end

        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @attrs
          assigns(:produce).should eq(@produce)
        end
      end

      describe "with invalid params" do
        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested produce" do
          put :update, :id => @produce.id, :produce => @attrs
        end

        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @attrs
          assigns(:produce).should eq(@produce)
          response.should redirect_to(@produce)
        end
      end

      describe "with invalid params" do
        it "assigns the produce as @produce" do
          put :update, :id => @produce, :produce => @invalid_attrs
          assigns(:produce).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @produce, :produce => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested produce" do
          put :update, :id => @produce.id, :produce => @attrs
        end

        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @attrs
          assigns(:produce).should eq(@produce)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested produce" do
          put :update, :id => @produce.id, :produce => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @produce.id, :produce => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested produce as @produce" do
          put :update, :id => @produce.id, :produce => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @produce = FactoryGirl.create(:produce)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested produce" do
        delete :destroy, :id => @produce.id
      end

      it "redirects to the produces list" do
        delete :destroy, :id => @produce.id
        response.should redirect_to(produces_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested produce" do
        delete :destroy, :id => @produce.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @produce.id
        response.should redirect_to(produces_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested produce" do
        delete :destroy, :id => @produce.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @produce.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested produce" do
        delete :destroy, :id => @produce.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @produce.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
