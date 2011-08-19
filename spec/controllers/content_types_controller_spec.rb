require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ContentTypesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:content_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end

    describe "When not logged in" do
      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:content_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created content_type as @content_type" do
          post :create, :content_type => @attrs
          assigns(:content_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved content_type as @content_type" do
          post :create, :content_type => @invalid_attrs
          assigns(:content_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created content_type as @content_type" do
          post :create, :content_type => @attrs
          assigns(:content_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved content_type as @content_type" do
          post :create, :content_type => @invalid_attrs
          assigns(:content_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created content_type as @content_type" do
          post :create, :content_type => @attrs
          assigns(:content_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved content_type as @content_type" do
          post :create, :content_type => @invalid_attrs
          assigns(:content_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created content_type as @content_type" do
          post :create, :content_type => @attrs
          assigns(:content_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved content_type as @content_type" do
          post :create, :content_type => @invalid_attrs
          assigns(:content_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :content_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @content_type = FactoryGirl.create(:content_type)
      @attrs = FactoryGirl.attributes_for(:content_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
        end

        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
          assigns(:content_type).should eq(@content_type)
        end

        it "moves its position when specified" do
          put :update, :id => @content_type.id, :content_type => @attrs, :position => 2
          response.should redirect_to(content_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
        end

        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
          assigns(:content_type).should eq(@content_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
        end

        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
          assigns(:content_type).should eq(@content_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @content_type.id, :content_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @content_type = FactoryGirl.create(:content_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
