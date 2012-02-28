require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ContentTypesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:content_type)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:content_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all content_types as @content_types" do
        get :index
        assigns(:content_types).should eq(ContentType.all)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :show, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested content_type as @content_type" do
        get :new
        assigns(:content_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        assigns(:content_type).should eq(content_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested content_type as @content_type" do
        content_type = FactoryGirl.create(:content_type)
        get :edit, :id => content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

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
      login_librarian

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
      login_user

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
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
        end

        it "assigns the requested content_type as @content_type" do
          put :update, :id => @content_type.id, :content_type => @attrs
          assigns(:content_type).should eq(@content_type)
        end

        it "moves its position when specified" do
          put :update, :id => @content_type.id, :content_type => @attrs, :move => 'lower'
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
      login_librarian

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
      login_user

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
      login_admin

      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested content_type" do
        delete :destroy, :id => @content_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @content_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

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
