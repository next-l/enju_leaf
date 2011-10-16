require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SubjectHasClassificationsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:subject_has_classification)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all subject_has_classifications as @subject_has_classifications" do
        get :index
        assigns(:subject_has_classifications).should eq(SubjectHasClassification.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all subject_has_classifications as @subject_has_classifications" do
        get :index
        assigns(:subject_has_classifications).should eq(SubjectHasClassification.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all subject_has_classifications as @subject_has_classifications" do
        get :index
        assigns(:subject_has_classifications).should eq(SubjectHasClassification.page(1))
      end
    end

    describe "When not logged in" do
      it "should not assign subject_has_classifications as @subject_has_classifications" do
        get :index
        assigns(:subject_has_classifications).should eq(SubjectHasClassification.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :show, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :show, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :show, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end

    describe "When not logged in" do
      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :show, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        get :new
        assigns(:subject_has_classification).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        get :new
        assigns(:subject_has_classification).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested subject_has_classification as @subject_has_classification" do
        get :new
        assigns(:subject_has_classification).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_has_classification as @subject_has_classification" do
        get :new
        assigns(:subject_has_classification).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :edit, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :edit, :id => subject_has_classification.id
        assigns(:subject_has_classification).should eq(subject_has_classification)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :edit, :id => subject_has_classification.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject_has_classification as @subject_has_classification" do
        subject_has_classification = FactoryGirl.create(:subject_has_classification)
        get :edit, :id => subject_has_classification.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:subject_has_classification)
      @invalid_attrs = {:subject_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should be_valid
        end

        it "redirects to the created subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          response.should redirect_to(subject_has_classification_url(assigns(:subject_has_classification)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @invalid_attrs
          assigns(:subject_has_classification).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :subject_has_classification => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should be_valid
        end

        it "redirects to the created subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          response.should redirect_to(subject_has_classification_url(assigns(:subject_has_classification)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @invalid_attrs
          assigns(:subject_has_classification).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :subject_has_classification => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_has_classification => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @invalid_attrs
          assigns(:subject_has_classification).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_has_classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject_has_classification => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject_has_classification as @subject_has_classification" do
          post :create, :subject_has_classification => @invalid_attrs
          assigns(:subject_has_classification).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject_has_classification => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @subject_has_classification = FactoryGirl.create(:subject_has_classification)
      @attrs = FactoryGirl.attributes_for(:subject_has_classification)
      @invalid_attrs = {:subject_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
        end

        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should eq(@subject_has_classification)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
        end

        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should eq(@subject_has_classification)
          response.should redirect_to(@subject_has_classification)
        end
      end

      describe "with invalid params" do
        it "assigns the subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification, :subject_has_classification => @invalid_attrs
          assigns(:subject_has_classification).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @subject_has_classification, :subject_has_classification => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
        end

        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
          assigns(:subject_has_classification).should eq(@subject_has_classification)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject_has_classification as @subject_has_classification" do
          put :update, :id => @subject_has_classification.id, :subject_has_classification => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @subject_has_classification = FactoryGirl.create(:subject_has_classification)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested subject_has_classification" do
        delete :destroy, :id => @subject_has_classification.id
      end

      it "redirects to the subject_has_classifications list" do
        delete :destroy, :id => @subject_has_classification.id
        response.should redirect_to(subject_has_classifications_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested subject_has_classification" do
        delete :destroy, :id => @subject_has_classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_has_classification.id
        response.should redirect_to(subject_has_classifications_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested subject_has_classification" do
        delete :destroy, :id => @subject_has_classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_has_classification.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested subject_has_classification" do
        delete :destroy, :id => @subject_has_classification.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject_has_classification.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
