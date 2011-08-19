require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe WorkHasSubjectsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:work_has_subject)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all work_has_subjects as @work_has_subjects" do
        get :index
        assigns(:work_has_subjects).should eq(WorkHasSubject.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all work_has_subjects as @work_has_subjects" do
        get :index
        assigns(:work_has_subjects).should eq(WorkHasSubject.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all work_has_subjects as @work_has_subjects" do
        get :index
        assigns(:work_has_subjects).should eq(WorkHasSubject.all)
      end
    end

    describe "When not logged in" do
      it "should not assign work_has_subjects as @work_has_subjects" do
        get :index
        assigns(:work_has_subjects).should eq(WorkHasSubject.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :show, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :show, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :show, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end

    describe "When not logged in" do
      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :show, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        get :new
        assigns(:work_has_subject).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        get :new
        assigns(:work_has_subject).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested work_has_subject as @work_has_subject" do
        get :new
        assigns(:work_has_subject).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested work_has_subject as @work_has_subject" do
        get :new
        assigns(:work_has_subject).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :edit, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :edit, :id => work_has_subject.id
        assigns(:work_has_subject).should eq(work_has_subject)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :edit, :id => work_has_subject.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested work_has_subject as @work_has_subject" do
        work_has_subject = FactoryGirl.create(:work_has_subject)
        get :edit, :id => work_has_subject.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:work_has_subject)
      @invalid_attrs = {:work_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @attrs
          assigns(:work_has_subject).should be_valid
        end

        it "redirects to the created work_has_subject" do
          post :create, :work_has_subject => @attrs
          response.should redirect_to(work_has_subject_url(assigns(:work_has_subject)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @invalid_attrs
          assigns(:work_has_subject).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :work_has_subject => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @attrs
          assigns(:work_has_subject).should be_valid
        end

        it "redirects to the created work_has_subject" do
          post :create, :work_has_subject => @attrs
          response.should redirect_to(work_has_subject_url(assigns(:work_has_subject)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @invalid_attrs
          assigns(:work_has_subject).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :work_has_subject => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @attrs
          assigns(:work_has_subject).should be_valid
        end

        it "should be forbidden" do
          post :create, :work_has_subject => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @invalid_attrs
          assigns(:work_has_subject).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :work_has_subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @attrs
          assigns(:work_has_subject).should be_valid
        end

        it "should be forbidden" do
          post :create, :work_has_subject => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved work_has_subject as @work_has_subject" do
          post :create, :work_has_subject => @invalid_attrs
          assigns(:work_has_subject).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :work_has_subject => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @work_has_subject = FactoryGirl.create(:work_has_subject)
      @attrs = FactoryGirl.attributes_for(:work_has_subject)
      @invalid_attrs = {:work_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
        end

        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
          assigns(:work_has_subject).should eq(@work_has_subject)
        end
      end

      describe "with invalid params" do
        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
        end

        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
          assigns(:work_has_subject).should eq(@work_has_subject)
          response.should redirect_to(@work_has_subject)
        end
      end

      describe "with invalid params" do
        it "assigns the work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject, :work_has_subject => @invalid_attrs
          assigns(:work_has_subject).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @work_has_subject, :work_has_subject => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
        end

        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
          assigns(:work_has_subject).should eq(@work_has_subject)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested work_has_subject as @work_has_subject" do
          put :update, :id => @work_has_subject.id, :work_has_subject => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @work_has_subject = FactoryGirl.create(:work_has_subject)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested work_has_subject" do
        delete :destroy, :id => @work_has_subject.id
      end

      it "redirects to the work_has_subjects list" do
        delete :destroy, :id => @work_has_subject.id
        response.should redirect_to(work_has_subjects_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested work_has_subject" do
        delete :destroy, :id => @work_has_subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @work_has_subject.id
        response.should redirect_to(work_has_subjects_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested work_has_subject" do
        delete :destroy, :id => @work_has_subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @work_has_subject.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested work_has_subject" do
        delete :destroy, :id => @work_has_subject.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @work_has_subject.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
