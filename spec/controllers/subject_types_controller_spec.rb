require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SubjectTypesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      Factory.create(:subject_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all subject_types as @subject_types" do
        get :index
        assigns(:subject_types).should eq(SubjectType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all subject_types as @subject_types" do
        get :index
        assigns(:subject_types).should eq(SubjectType.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all subject_types as @subject_types" do
        get :index
        assigns(:subject_types).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all subject_types as @subject_types" do
        get :index
        assigns(:subject_types).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :show, :id => subject_type.id
        assigns(:subject_type).should eq(subject_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :show, :id => subject_type.id
        assigns(:subject_type).should eq(subject_type)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :show, :id => subject_type.id
        assigns(:subject_type).should eq(subject_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :show, :id => subject_type.id
        assigns(:subject_type).should eq(subject_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested subject_type as @subject_type" do
        get :new
        assigns(:subject_type).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested subject_type as @subject_type" do
        get :new
        assigns(:subject_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested subject_type as @subject_type" do
        get :new
        assigns(:subject_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_type as @subject_type" do
        get :new
        assigns(:subject_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :edit, :id => subject_type.id
        assigns(:subject_type).should eq(subject_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :edit, :id => subject_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :edit, :id => subject_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_type as @subject_type" do
        subject_type = Factory.create(:subject_type)
        get :edit, :id => subject_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:subject_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created subject_type as @subject_type" do
          post :create, :subject_type => @attrs
          assigns(:subject_type).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :subject_type => @attrs
          response.should redirect_to(assigns(:subject_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_type as @subject_type" do
          post :create, :subject_type => @invalid_attrs
          assigns(:subject_type).should_not be_valid
        end

        it "should be successful" do
          post :create, :subject_type => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created subject_type as @subject_type" do
          post :create, :subject_type => @attrs
          assigns(:subject_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_type as @subject_type" do
          post :create, :subject_type => @invalid_attrs
          assigns(:subject_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created subject_type as @subject_type" do
          post :create, :subject_type => @attrs
          assigns(:subject_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_type as @subject_type" do
          post :create, :subject_type => @invalid_attrs
          assigns(:subject_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created subject_type as @subject_type" do
          post :create, :subject_type => @attrs
          assigns(:subject_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_type as @subject_type" do
          post :create, :subject_type => @invalid_attrs
          assigns(:subject_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @subject_type = Factory(:subject_type)
      @attrs = Factory.attributes_for(:subject_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
        end

        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
          assigns(:subject_type).should eq(@subject_type)
        end

        it "moves its position when specified" do
          put :update, :id => @subject_type.id, :subject_type => @attrs, :position => 2
          response.should redirect_to(subject_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
        end

        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
          assigns(:subject_type).should eq(@subject_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
        end

        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
          assigns(:subject_type).should eq(@subject_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subject_type.id, :subject_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_type as @subject_type" do
          put :update, :id => @subject_type.id, :subject_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @subject_type = Factory(:subject_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested subject_type" do
        delete :destroy, :id => @subject_type.id
      end

      it "redirects to the subject_types list" do
        delete :destroy, :id => @subject_type.id
        response.should redirect_to(subject_types_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested subject_type" do
        delete :destroy, :id => @subject_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested subject_type" do
        delete :destroy, :id => @subject_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested subject_type" do
        delete :destroy, :id => @subject_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
