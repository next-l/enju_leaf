require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe CreatesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:create)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all creates as @creates" do
        get :index
        assigns(:creates).should eq(Create.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all creates as @creates" do
        get :index
        assigns(:creates).should eq(Create.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all creates as @creates" do
        get :index
        assigns(:creates).should eq(Create.all)
      end
    end

    describe "When not logged in" do
      it "assigns all creates as @creates" do
        get :index
        assigns(:creates).should eq(Create.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :show, :id => create.id
        assigns(:create).should eq(create)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :show, :id => create.id
        assigns(:create).should eq(create)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :show, :id => create.id
        assigns(:create).should eq(create)
      end
    end

    describe "When not logged in" do
      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :show, :id => create.id
        assigns(:create).should eq(create)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested create as @create" do
        get :new
        assigns(:create).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested create as @create" do
        get :new
        assigns(:create).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested create as @create" do
        get :new
        assigns(:create).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested create as @create" do
        get :new
        assigns(:create).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :edit, :id => create.id
        assigns(:create).should eq(create)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :edit, :id => create.id
        assigns(:create).should eq(create)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :edit, :id => create.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested create as @create" do
        create = FactoryGirl.create(:create)
        get :edit, :id => create.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:create)
      @invalid_attrs = {:work_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created create as @create" do
          post :create, :create => @attrs
          assigns(:create).should be_valid
        end

        it "redirects to the created create" do
          post :create, :create => @attrs
          response.should redirect_to(create_url(assigns(:create)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved create as @create" do
          post :create, :create => @invalid_attrs
          assigns(:create).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :create => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created create as @create" do
          post :create, :create => @attrs
          assigns(:create).should be_valid
        end

        it "redirects to the created create" do
          post :create, :create => @attrs
          response.should redirect_to(create_url(assigns(:create)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved create as @create" do
          post :create, :create => @invalid_attrs
          assigns(:create).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :create => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created create as @create" do
          post :create, :create => @attrs
          assigns(:create).should be_valid
        end

        it "should be forbidden" do
          post :create, :create => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved create as @create" do
          post :create, :create => @invalid_attrs
          assigns(:create).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :create => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created create as @create" do
          post :create, :create => @attrs
          assigns(:create).should be_valid
        end

        it "should be forbidden" do
          post :create, :create => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved create as @create" do
          post :create, :create => @invalid_attrs
          assigns(:create).should_not be_valid
        end

        it "should be redirected to new session url" do
          post :create, :create => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @create = FactoryGirl.create(:create)
      @attrs = FactoryGirl.attributes_for(:create)
      @invalid_attrs = {:work_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested create" do
          put :update, :id => @create.id, :create => @attrs
        end

        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @attrs
          assigns(:create).should eq(@create)
        end
      end

      describe "with invalid params" do
        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested create" do
          put :update, :id => @create.id, :create => @attrs
        end

        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @attrs
          assigns(:create).should eq(@create)
          response.should redirect_to(@create)
        end
      end

      describe "with invalid params" do
        it "assigns the create as @create" do
          put :update, :id => @create, :create => @invalid_attrs
          assigns(:create).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @create, :create => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested create" do
          put :update, :id => @create.id, :create => @attrs
        end

        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @attrs
          assigns(:create).should eq(@create)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested create" do
          put :update, :id => @create.id, :create => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @create.id, :create => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested create as @create" do
          put :update, :id => @create.id, :create => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @create = FactoryGirl.create(:create)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested create" do
        delete :destroy, :id => @create.id
      end

      it "redirects to the creates list" do
        delete :destroy, :id => @create.id
        response.should redirect_to(creates_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested create" do
        delete :destroy, :id => @create.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @create.id
        response.should redirect_to(creates_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested create" do
        delete :destroy, :id => @create.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @create.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested create" do
        delete :destroy, :id => @create.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @create.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
