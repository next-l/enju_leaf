require 'rails_helper'

describe AnswersController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all answers as @answers" do
        get :index
        assigns(:answers).should_not be_empty
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns nil as @answers" do
        get :index
        assigns(:answers).should be_nil
      end

      it "should not get index" do
        get :index
        response.should be_forbidden
        assigns(:answers).should be_nil
      end

      it "should get to my index if user_id is specified" do
        get :index, params: { user_id: users(:user1).username }
        response.should be_successful
        assigns(:answers).should eq users(:user1).answers.order('answers.id DESC').page(1)
      end

      it "should not get other user's index without user_id" do
        get :index, params: { user_id: users(:user2).username }
        response.should be_forbidden
      end

      it "should get my index feed" do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        response.should be_successful
        assigns(:answers).should_not be_empty
      end

      it "should not get other user's index if question is not shared" do
        get :index, params: { user_id: users(:librarian1).username, question_id: 2 }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @answers" do
        get :index
        assigns(:answers).should be_nil
        response.should redirect_to new_user_session_url
      end

      it "should not get index with other user's question_id" do
        get :index, params: { question_id: 1 }
        assigns(:answers).should eq assigns(:question).answers.order('answers.id DESC').page(1)
        response.should be_successful
      end

      it "should get other user's index if question is shared" do
        get :index, params: { question_id: 5 }
        response.should be_successful
        assigns(:answers).should eq assigns(:question).answers.order('answers.id DESC').page(1)
      end

      it "should not get other user's index feed if question is not shared" do
        get :index, params: { question_id: 2, format: 'rss' }
        response.should be_client_error
      end

      it "should get other user's index feed if question is shared" do
        get :index, params: { question_id: 5, format: 'rss' }
        response.should be_successful
        assigns(:answers).should eq assigns(:question).answers.order('answers.id DESC').page(1)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :show, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_user

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :show, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :show, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end

      it "should show answer without user_id" do
        get :show, params: { id: 1, question_id: 1 }
        assigns(:answer).should eq(answers(:answer_00001))
        assert_response :success
      end

      it "should show public answer without question_id" do
        get :show, params: { id: 3, user_id: users(:user1).username }
        assigns(:answer).should eq(Answer.find(3))
        assert_response :success
      end

      it "should show my answer" do
        get :show, params: { id: 3, user_id: users(:user1).username }
        assigns(:answer).should eq(Answer.find(3))
        assert_response :success
      end

      it "should not show private answer" do
        get :show, params: { id: 4, user_id: users(:user1).username }
        response.should be_forbidden
      end

      it "should not show missing answer" do
        lambda {
          get :show, params: { id: 'missing', user_id: users(:user1).username, question_id: 1 }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end

      it "should not show answer with other user's user_id" do
        get :show, params: { id: 5, user_id: users(:user2).username, question_id: 2 }
        response.should be_forbidden
      end

      it "should not show answer without other user's user_id" do
        get :show, params: { id: 5, question_id: 2 }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :show, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end

      it "should show public_answer" do
        get :show, params: { id: 1, question_id: 1 }
        assigns(:answer).should eq(Answer.find(1))
        response.should be_successful
      end

      it "should not show private answer" do
        get :show, params: { id: 4, question_id: 1 }
        assigns(:answer).should eq(Answer.find(4))
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested answer as @answer" do
        get :new
        assigns(:answer).should be_nil
        response.should redirect_to questions_url
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_user

      it "assigns the requested answer as @answer" do
        get :new
        assigns(:answer).should be_nil
        response.should redirect_to questions_url
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should assign the requested answer as @answer" do
        get :new
        assigns(:answer).should be_nil
        response.should redirect_to questions_url
      end

      it "should get new template with question_id" do
        get :new, params: { question_id: 1 }
        assigns(:answer).should_not be_valid
        response.should be_successful
      end
    end

    describe "When not logged in" do
      it "should not assign the requested answer as @answer" do
        get :new
        assigns(:answer).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :edit, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_user

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :edit, params: { id: answer.id }
        assigns(:answer).should eq(answer)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :edit, params: { id: answer.id }
        response.should be_forbidden
      end

      it "should edit my answer without user_id" do
        get :edit, params: { id: 3, question_id: 1 }
        response.should be_successful
      end

      it "should not edit other answer without user_id" do
        get :edit, params: { id: 4, question_id: 1 }
        response.should be_forbidden
      end

      it "should edit answer without question_id" do
        get :edit, params: { id: 3, user_id: users(:user1).username }
        response.should be_successful
      end

      it "should not edit missing answer" do
        lambda {
          get :edit, params: { id: 100, user_id: users(:user1).username, question_id: 1 }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end

      it "should edit my answer" do
        get :edit, params: { id: 3, user_id: users(:user1).username, question_id: 1 }
        response.should be_successful
      end

      it "should not edit other user's answer" do
        get :edit, params: { id: 5, user_id: users(:user2).username, question_id: 2 }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested answer as @answer" do
        answer = FactoryBot.create(:answer)
        get :edit, params: { id: answer.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:answer)
      @invalid_attrs = { body: '' }
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should create answer without user_id" do
        post :create, params: { answer: { question_id: 1, body: 'hoge' } }
        response.should redirect_to answer_url(assigns(:answer))
      end

      it "should not create answer without question_id" do
        post :create, params: { answer: { body: 'hoge' } }
        assigns(:answer).should_not be_valid
        response.should redirect_to questions_url
      end

      it "should create answer with question_id" do
        post :create, params: { answer: { question_id: 1, body: 'hoge' } }
        assigns(:answer).should be_valid
        response.should redirect_to answer_url(assigns(:answer))
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created answer as @answer" do
          post :create, params: { answer: @attrs }
          assigns(:answer).should be_nil
        end

        it "redirects to the created answer" do
          post :create, params: { answer: @attrs }
          response.should redirect_to new_user_session_url
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved answer as @answer" do
          post :create, params: { answer: @invalid_attrs }
          assigns(:answer).should be_nil
        end

        it "re-renders the 'new' template" do
          post :create, params: { answer: @invalid_attrs }
          response.should redirect_to new_user_session_url
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @answer = answers(:answer_00001)
      @attrs = { body: 'test' }
      @invalid_attrs = { body: '' }
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
        end

        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
          assigns(:answer).should eq(Answer.find(3))
        end
      end

      describe "with invalid params" do
        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
        end

        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
          assigns(:answer).should eq(Answer.find(3))
        end
      end

      describe "with invalid params" do
        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @invalid_attrs }
          response.should render_template("edit")
        end
      end

      it "should update other user's answer" do
        put :update, params: { id: 3, answer: { body: 'test' }, user_id: users(:user1).username }
        response.should redirect_to answer_url(assigns(:answer))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
        end

        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @attrs }
          assigns(:answer).should eq(Answer.find(3))
        end
      end

      describe "with invalid params" do
        it "assigns the requested answer as @answer" do
          put :update, params: { id: answers(:answer_00003).id, answer: @invalid_attrs }
          response.should render_template("edit")
        end
      end

      it "should update my answer" do
        put :update, params: { id: answers(:answer_00003), answer: { body: 'test' }, user_id: users(:user1).username }
        response.should redirect_to answer_url(assigns(:answer))
      end

      it "should not update missing answer" do
        lambda {
          put :update, params: { id: 'missing', answer: { body: 'test' }, user_id: users(:user1).username }
        }.should raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end

      it "should not update other user's answer" do
        put :update, params: { id: 5, answer: { body: 'test' }, user_id: users(:user2).username }
        response.should be_forbidden
      end

      it "should update my answer with question_id" do
        put :update, params: { id: 3, answer: { body: 'test' }, user_id: users(:user1).username, question_id: 1 }
        response.should redirect_to answer_url(assigns(:answer))
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested answer" do
          put :update, params: { id: @answer.id, answer: @attrs }
        end

        it "assigns the requested answer as @answer" do
          put :update, params: { id: @answer.id, answer: @attrs }
          assigns(:answer).should eq(@answer)
          response.should redirect_to new_user_session_url
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as User" do
      login_fixture_user

      it "should destroy my answer" do
        delete :destroy, params: { id: 3 }
        response.should redirect_to question_answers_url(assigns(:answer).question)
      end

      it "should not destroy other user's answer" do
        delete :destroy, params: { id: 5 }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be forbidden" do
        delete :destroy, params: { id: 1 }
        response.should redirect_to new_user_session_url
      end
    end
  end
end
