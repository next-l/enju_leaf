require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe RealizesController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.all)
      end
    end

    describe "When not logged in" do
      it "assigns all realizes as @realizes" do
        get :index
        assigns(:realizes).should eq(Realize.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When not logged in" do
      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :show, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested realize as @realize" do
        get :new
        assigns(:realize).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        assigns(:realize).should eq(realize)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested realize as @realize" do
        realize = FactoryGirl.create(:realize)
        get :edit, :id => realize.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:realize)
      @invalid_attrs = {:expression_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "redirects to the created realize" do
          post :create, :realize => @attrs
          response.should redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :realize => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "redirects to the created realize" do
          post :create, :realize => @attrs
          response.should redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :realize => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created realize as @realize" do
          post :create, :realize => @attrs
          assigns(:realize).should be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved realize as @realize" do
          post :create, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :realize => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @realize = FactoryGirl.create(:realize)
      @attrs = FactoryGirl.attributes_for(:realize)
      @invalid_attrs = {:expression_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should redirect_to(@realize)
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should redirect_to(@realize)
        end
      end

      describe "with invalid params" do
        it "assigns the realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          assigns(:realize).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @attrs
          assigns(:realize).should eq(@realize)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested realize" do
          put :update, :id => @realize.id, :realize => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @realize.id, :realize => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested realize as @realize" do
          put :update, :id => @realize.id, :realize => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @realize = FactoryGirl.create(:realize)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "redirects to the realizes list" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(realizes_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "redirects to the realizes list" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(realizes_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @realize.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested realize" do
        delete :destroy, :id => @realize.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @realize.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
