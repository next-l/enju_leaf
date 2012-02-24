require 'spec_helper'

describe SubjectsController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all subjects as @subjects" do
        get :index
        assigns(:subjects).should_not be_nil
      end

      it "assigns all subjects as @subjects with work_id" do
        get :index, :work_id => 1
        assigns(:subjects).should_not be_nil
      end
    end
  end

  describe "GET show", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :show, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :show, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :show, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end

    describe "When not logged in" do
      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :show, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject as @subject" do
        get :new
        assigns(:subject).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject as @subject" do
        get :new
        assigns(:subject).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested subject as @subject" do
        get :new
        assigns(:subject).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject as @subject" do
        get :new
        assigns(:subject).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :edit, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :edit, :id => subject.id
        assigns(:subject).should eq(subject)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :edit, :id => subject.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subject as @subject" do
        subject = FactoryGirl.create(:subject)
        get :edit, :id => subject.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:subject)
      @invalid_attrs = {:term => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created subject as @subject" do
          post :create, :subject => @attrs
          assigns(:subject).should be_valid
        end

        it "redirects to the created subject" do
          post :create, :subject => @attrs
          response.should redirect_to(subject_url(assigns(:subject)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject as @subject" do
          post :create, :subject => @invalid_attrs
          assigns(:subject).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :subject => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created subject as @subject" do
          post :create, :subject => @attrs
          assigns(:subject).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject as @subject" do
          post :create, :subject => @invalid_attrs
          assigns(:subject).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created subject as @subject" do
          post :create, :subject => @attrs
          assigns(:subject).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject as @subject" do
          post :create, :subject => @invalid_attrs
          assigns(:subject).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created subject as @subject" do
          post :create, :subject => @attrs
          assigns(:subject).should be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subject as @subject" do
          post :create, :subject => @invalid_attrs
          assigns(:subject).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subject => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @subject = FactoryGirl.create(:subject)
      @attrs = FactoryGirl.attributes_for(:subject)
      @invalid_attrs = {:term => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested subject" do
          put :update, :id => @subject.id, :subject => @attrs
        end

        it "assigns the requested subject as @subject" do
          put :update, :id => @subject.id, :subject => @attrs
          assigns(:subject).should eq(@subject)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject as @subject" do
          put :update, :id => @subject.id, :subject => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested subject" do
          put :update, :id => @subject.id, :subject => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subject.id, :subject => @attrs
          assigns(:subject).should eq(@subject)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "should be forbidden" do
          put :update, :id => @subject, :subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested subject" do
          put :update, :id => @subject.id, :subject => @attrs
        end

        it "assigns the requested subject as @subject" do
          put :update, :id => @subject.id, :subject => @attrs
          assigns(:subject).should eq(@subject)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject as @subject" do
          put :update, :id => @subject.id, :subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested subject" do
          put :update, :id => @subject.id, :subject => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subject.id, :subject => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subject as @subject" do
          put :update, :id => @subject.id, :subject => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @subject = FactoryGirl.create(:subject)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested subject" do
        delete :destroy, :id => @subject.id
      end

      it "redirects to the subjects list" do
        delete :destroy, :id => @subject.id
        response.should redirect_to(subjects_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested subject" do
        delete :destroy, :id => @subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested subject" do
        delete :destroy, :id => @subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested subject" do
        delete :destroy, :id => @subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subject.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
