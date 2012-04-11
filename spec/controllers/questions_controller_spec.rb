require 'spec_helper'

describe QuestionsController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end

      it "assigns all questions as @questionsin rss format" do
        get :index, :format => 'rss'
        assigns(:questions).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When not logged in" do
      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :show, :id => question.id
        assigns(:question).should eq(question)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should assign the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :edit, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :edit, :id => question.id
        assigns(:question).should eq(question)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :edit, :id => question.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested question as @question" do
        question = FactoryGirl.create(:question)
        get :edit, :id => question.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:question)
      @invalid_attrs = {:body => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, :question => @attrs
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, :question => @attrs
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, :question => @invalid_attrs
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :question => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, :question => @attrs
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, :question => @attrs
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, :question => @invalid_attrs
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :question => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, :question => @attrs
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, :question => @attrs
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, :question => @invalid_attrs
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :question => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, :question => @attrs
          assigns(:question).should be_valid
        end

        it "should be forbidden" do
          post :create, :question => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, :question => @invalid_attrs
          assigns(:question).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :question => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @question = FactoryGirl.create(:question)
      @attrs = FactoryGirl.attributes_for(:question)
      @invalid_attrs = {:body => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
        end

        it "assigns the requested question as @question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
          assigns(:question).should eq(@question)
        end
      end

      describe "with invalid params" do
        it "assigns the requested question as @question" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
        end

        it "assigns the requested question as @question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
          assigns(:question).should eq(@question)
          response.should redirect_to(@question)
        end
      end

      describe "with invalid params" do
        it "assigns the question as @question" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
        end

        it "should be forbidden" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
          assigns(:question).should eq(@question)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the question as @question" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
        end

        it "should be forbidden" do
          put :update, :id => @question.id, :question => @invalid_attrs, :user_id => @question.username
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested question" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
        end

        it "should be forbidden" do
          put :update, :id => @question.id, :question => @attrs, :user_id => @question.username
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested question as @question" do
          put :update, :id => @question.id, :question => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @question = FactoryGirl.create(:question)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested question" do
        delete :destroy, :id => @question.id
      end

      it "redirects to the questions list" do
        delete :destroy, :id => @question.id
        response.should redirect_to(questions_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested question" do
        delete :destroy, :id => @question.id
      end

      it "redirects to the questions list" do
        delete :destroy, :id => @question.id
        response.should redirect_to(questions_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested question" do
        delete :destroy, :id => @question.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @question.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested question" do
        delete :destroy, :id => @question.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @question.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
