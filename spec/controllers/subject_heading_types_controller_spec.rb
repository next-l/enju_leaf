require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SubjectHeadingTypesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:subject_heading_type)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:subject_heading_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all subject_heading_types as @subject_heading_types" do
        get :index
        assigns(:subject_heading_types).should eq(SubjectHeadingType.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all subject_heading_types as @subject_heading_types" do
        get :index
        assigns(:subject_heading_types).should eq(SubjectHeadingType.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all subject_heading_types as @subject_heading_types" do
        get :index
        assigns(:subject_heading_types).should eq(SubjectHeadingType.all)
      end
    end

    describe "When not logged in" do
      it "assigns all subject_heading_types as @subject_heading_types" do
        get :index
        assigns(:subject_heading_types).should eq(SubjectHeadingType.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :show, :id => subject_heading_type.id
        assigns(:subject_heading_type).should eq(subject_heading_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :show, :id => subject_heading_type.id
        assigns(:subject_heading_type).should eq(subject_heading_type)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :show, :id => subject_heading_type.id
        assigns(:subject_heading_type).should eq(subject_heading_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :show, :id => subject_heading_type.id
        assigns(:subject_heading_type).should eq(subject_heading_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        get :new
        assigns(:subject_heading_type).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested subject_heading_type as @subject_heading_type" do
        get :new
        assigns(:subject_heading_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested subject_heading_type as @subject_heading_type" do
        get :new
        assigns(:subject_heading_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_heading_type as @subject_heading_type" do
        get :new
        assigns(:subject_heading_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :edit, :id => subject_heading_type.id
        assigns(:subject_heading_type).should eq(subject_heading_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :edit, :id => subject_heading_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :edit, :id => subject_heading_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_heading_type as @subject_heading_type" do
        subject_heading_type = FactoryGirl.create(:subject_heading_type)
        get :edit, :id => subject_heading_type.id
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
        it "assigns a newly created subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :subject_heading_type => @attrs
          response.should redirect_to(assigns(:subject_heading_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @invalid_attrs
          assigns(:subject_heading_type).should_not be_valid
        end

        it "should be successful" do
          post :create, :subject_heading_type => @invalid_attrs
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @invalid_attrs
          assigns(:subject_heading_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @invalid_attrs
          assigns(:subject_heading_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_heading_type as @subject_heading_type" do
          post :create, :subject_heading_type => @invalid_attrs
          assigns(:subject_heading_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_heading_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @subject_heading_type = FactoryGirl.create(:subject_heading_type)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
        end

        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should eq(@subject_heading_type)
        end

        it "moves its position when specified" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs, :move => 'lower'
          response.should redirect_to(subject_heading_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
        end

        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should eq(@subject_heading_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
        end

        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
          assigns(:subject_heading_type).should eq(@subject_heading_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_heading_type as @subject_heading_type" do
          put :update, :id => @subject_heading_type.id, :subject_heading_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @subject_heading_type = FactoryGirl.create(:subject_heading_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested subject_heading_type" do
        delete :destroy, :id => @subject_heading_type.id
      end

      it "redirects to the subject_heading_types list" do
        delete :destroy, :id => @subject_heading_type.id
        response.should redirect_to(subject_heading_types_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested subject_heading_type" do
        delete :destroy, :id => @subject_heading_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_heading_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested subject_heading_type" do
        delete :destroy, :id => @subject_heading_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_heading_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested subject_heading_type" do
        delete :destroy, :id => @subject_heading_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_heading_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
