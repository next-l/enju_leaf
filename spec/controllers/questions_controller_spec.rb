require 'rails_helper'

describe QuestionsController do
  fixtures :all

  describe "GET index", solr: true do
    before do
      Question.reindex
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end

      it "assigns all questions as @questionsin rss format" do
        get :index, format: :rss
        assigns(:questions).should_not be_nil
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end

      it "should get my index feed" do
        get :index, format: :rss
        response.should be_successful
        assigns(:questions).should eq Question.public_questions.order(:updated_at).page(1)
      end

      it "should redirect_to my index feed if user_id is specified" do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        response.should be_successful
        assigns(:questions).should eq users(:user1).questions
      end

      it "should get other user's index" do
        get :index, params: { user_id: users(:user2).username }
        response.should be_successful
        assigns(:questions).should_not be_empty
      end

      it "should get other user's index feed" do
        get :index, params: { user_id: users(:user2).username, format: 'rss' }
        response.should be_successful
        assigns(:questions).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all questions as @questions" do
        get :index
        assigns(:questions).should_not be_nil
      end

      it "should get index with query", vcr: true do
        get :index, params: { query: 'Yahoo' }
        response.should be_successful
        assigns(:questions).should_not be_nil
        assigns(:crd_results).should_not be_nil
      end

      it "should render crd_xml template", vcr: true do
        get :index, params: { query: 'Yahoo', mode: 'crd', format: :xml }
        response.should be_successful
        response.should render_template("questions/index_crd")
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @question = FactoryBot.create(:question)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested question as @question" do
        get :show, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested question as @question" do
        get :show, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested question as @question" do
        get :show, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end

      it "should show other user's question" do
        get :show, params: { id: 5 }
        response.should be_successful
      end

      it "should not show missing question" do
        lambda {
          get :show, params: { id: 'missing' }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end

      it "should show my question" do
        get :show, params: { id: 3 }
        assigns(:question).should eq Question.find(3)
        response.should be_successful
      end

      it "should show other user's shared question" do
        get :show, params: { id: 5 }
        assigns(:question).should eq Question.find(5)
        response.should be_successful
      end
    end

    describe "When not logged in" do
      it "assigns the requested question as @question" do
        get :show, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end

      it "should show crd xml" do
        get :show, params: { id: @question.id, mode: 'crd', format: :xml }
        response.should be_successful
        response.should render_template("questions/show_crd")
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should assign the requested question as @question" do
        get :new
        assigns(:question).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested question as @question" do
        get :new
        assigns(:question).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @question = FactoryBot.create(:question)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested question as @question" do
        get :edit, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested question as @question" do
        get :edit, params: { id: @question.id }
        assigns(:question).should eq(@question)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested question as @question" do
        get :edit, params: { id: @question.id }
        response.should be_forbidden
      end

      it "should not edit other user's question" do
        get :edit, params: { id: 5 }
        response.should be_forbidden
      end

      it "should not edit missing question" do
        lambda {
          get :edit, params: { id: 'missing' }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end

      it "should edit my question" do
        get :edit, params: { id: 3 }
        response.should be_successful
      end
    end

    describe "When not logged in" do
      it "should not assign the requested question as @question" do
        get :edit, params: { id: @question.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:question)
      @invalid_attrs = { body: '' }
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, params: { question: @attrs }
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, params: { question: @attrs }
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, params: { question: @invalid_attrs }
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { question: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, params: { question: @attrs }
          assigns(:question).user.save!
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, params: { question: @attrs }
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, params: { question: @invalid_attrs }
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { question: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, params: { question: @attrs }
          assigns(:question).should be_valid
        end

        it "redirects to the created question" do
          post :create, params: { question: @attrs }
          response.should redirect_to(question_url(assigns(:question)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, params: { question: @invalid_attrs }
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { question: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created question as @question" do
          post :create, params: { question: @attrs }
          assigns(:question).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { question: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved question as @question" do
          post :create, params: { question: @invalid_attrs }
          assigns(:question).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { question: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @question = FactoryBot.create(:question)
      @attrs = FactoryBot.attributes_for(:question)
      @invalid_attrs = { body: '' }
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested question" do
          put :update, params: { id: @question.id, question: @attrs }
        end

        it "assigns the requested question as @question" do
          put :update, params: { id: @question.id, question: @attrs }
          assigns(:question).should eq(@question)
        end
      end

      describe "with invalid params" do
        it "assigns the requested question as @question" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
          response.should render_template("edit")
        end
      end

      it "should not update my question without body" do
        put :update, params: { id: 3, question: { body: "" } }
        assigns(:question).should_not be_valid
        response.should be_successful
      end

      it "should not update missing question" do
        lambda {
          put :update, params: { id: 'missing', question: {} }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested question" do
          put :update, params: { id: @question.id, question: @attrs }
        end

        it "assigns the requested question as @question" do
          put :update, params: { id: @question.id, question: @attrs }
          assigns(:question).should eq(@question)
          response.should redirect_to(@question)
        end
      end

      describe "with invalid params" do
        it "assigns the question as @question" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
          assigns(:question).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested question" do
          put :update, params: { id: @question.id, question: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @question.id, question: @attrs }
          assigns(:question).should eq(@question)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the question as @question" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
          response.should be_forbidden
        end
      end

      it "should update my question" do
        put :update, params: { id: 3, question: { body: 'test' } }
        assigns(:question).should eq Question.find(3)
        response.should redirect_to(assigns(:question))
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested question" do
          put :update, params: { id: @question.id, question: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @question.id, question: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested question as @question" do
          put :update, params: { id: @question.id, question: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @question = FactoryBot.create(:question)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested question" do
        delete :destroy, params: { id: @question.id }
      end

      it "redirects to the questions list" do
        delete :destroy, params: { id: @question.id }
        response.should redirect_to(user_questions_url(assigns(:question).user))
      end

      it "should not destroy missing question" do
        lambda {
          delete :destroy, params: { id: 'missing' }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested question" do
        delete :destroy, params: { id: @question.id }
      end

      it "redirects to the questions list" do
        delete :destroy, params: { id: @question.id }
        response.should redirect_to(user_questions_url(assigns(:question).user))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested question" do
        delete :destroy, params: { id: @question.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @question.id }
        response.should be_forbidden
      end

      it "should destroy my question" do
        delete :destroy, params: { id: 3 }
        response.should redirect_to user_questions_url(assigns(:question).user)
      end

      it "should not destroy other question" do
        delete :destroy, params: { id: 5 }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested question" do
        delete :destroy, params: { id: @question.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @question.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
