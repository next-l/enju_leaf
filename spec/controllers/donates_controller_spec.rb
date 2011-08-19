require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe DonatesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all donates as @donates" do
        get :index
        assigns(:donates).should eq(Donate.order('id DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all donates as @donates" do
        get :index
        assigns(:donates).should eq(Donate.order('id DESC').page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all donates as @donates" do
        get :index
        assigns(:donates).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all donates as @donates" do
        get :index
        assigns(:donates).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :show, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :show, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :show, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end

    describe "When not logged in" do
      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :show, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested donate as @donate" do
        get :new
        assigns(:donate).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested donate as @donate" do
        get :new
        assigns(:donate).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested donate as @donate" do
        get :new
        assigns(:donate).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested donate as @donate" do
        get :new
        assigns(:donate).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :edit, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :edit, :id => donate.id
        assigns(:donate).should eq(donate)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :edit, :id => donate.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested donate as @donate" do
        donate = FactoryGirl.create(:donate)
        get :edit, :id => donate.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:donate)
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created donate as @donate" do
          post :create, :donate => @attrs
          assigns(:donate).should be_valid
        end

        it "redirects to the created donate" do
          post :create, :donate => @attrs
          response.should redirect_to(donate_url(assigns(:donate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved donate as @donate" do
          post :create, :donate => @invalid_attrs
          assigns(:donate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :donate => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created donate as @donate" do
          post :create, :donate => @attrs
          assigns(:donate).should be_valid
        end

        it "redirects to the created donate" do
          post :create, :donate => @attrs
          response.should redirect_to(donate_url(assigns(:donate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved donate as @donate" do
          post :create, :donate => @invalid_attrs
          assigns(:donate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :donate => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created donate as @donate" do
          post :create, :donate => @attrs
          assigns(:donate).should be_valid
        end

        it "should be forbidden" do
          post :create, :donate => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved donate as @donate" do
          post :create, :donate => @invalid_attrs
          assigns(:donate).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :donate => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created donate as @donate" do
          post :create, :donate => @attrs
          assigns(:donate).should be_valid
        end

        it "should be forbidden" do
          post :create, :donate => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved donate as @donate" do
          post :create, :donate => @invalid_attrs
          assigns(:donate).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :donate => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @donate = FactoryGirl.create(:donate)
      @attrs = FactoryGirl.attributes_for(:donate)
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested donate" do
          put :update, :id => @donate.id, :donate => @attrs
        end

        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @attrs
          assigns(:donate).should eq(@donate)
        end
      end

      describe "with invalid params" do
        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested donate" do
          put :update, :id => @donate.id, :donate => @attrs
        end

        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @attrs
          assigns(:donate).should eq(@donate)
          response.should redirect_to(@donate)
        end
      end

      describe "with invalid params" do
        it "assigns the donate as @donate" do
          put :update, :id => @donate, :donate => @invalid_attrs
          assigns(:donate).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @donate, :donate => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested donate" do
          put :update, :id => @donate.id, :donate => @attrs
        end

        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @attrs
          assigns(:donate).should eq(@donate)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested donate" do
          put :update, :id => @donate.id, :donate => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @donate.id, :donate => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested donate as @donate" do
          put :update, :id => @donate.id, :donate => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @donate = FactoryGirl.create(:donate)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested donate" do
        delete :destroy, :id => @donate.id
      end

      it "redirects to the donates list" do
        delete :destroy, :id => @donate.id
        response.should redirect_to(donates_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested donate" do
        delete :destroy, :id => @donate.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @donate.id
        response.should redirect_to(donates_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested donate" do
        delete :destroy, :id => @donate.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @donate.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested donate" do
        delete :destroy, :id => @donate.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @donate.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
