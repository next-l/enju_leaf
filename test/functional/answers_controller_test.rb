require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
    fixtures :answers, :questions, :languages, :patrons, :patron_types,
      :user_groups, :users, :roles, :library_groups, :libraries, :countries,
      :manifestations, :items

  def test_guest_should_not_create_answer
    assert_no_difference('Answer.count') do
      post :create, :answer => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_create_answer_without_user_id
    sign_in users(:user1)
    assert_difference('Answer.count') do
      post :create, :answer => {:question_id => 1, :body => 'hoge'}
    end
    
    assert_redirected_to answer_url(assigns(:answer))
  end

  def test_user_should_not_create_answer_without_question_id
    sign_in users(:user1)
    assert_no_difference('Answer.count') do
      post :create, :answer => {:body => 'hoge'}
    end
    
    assert_response :redirect
    assert_redirected_to questions_url
  end

  def test_user_should_create_answer_with_question_id
    sign_in users(:user1)
    assert_difference('Answer.count') do
      post :create, :answer => {:question_id => 1, :body => 'hoge'}
    end
    
    assert_redirected_to answer_url(assigns(:answer))
  end

  def test_guest_should_not_update_answer
    put :update, :id => 1, :answer => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_answer
    sign_in users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).username
    assert_redirected_to answer_url(assigns(:answer))
  end
  
  def test_user_should_update_my_answer_with_question_id
    sign_in users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).username, :question_id => 1
    assert_redirected_to answer_url(assigns(:answer))
    #assert_redirected_to answer_url(assigns(:answer))
  end
  
  def test_user_should_not_update_missing_answer
    sign_in users(:user1)
    put :update, :id => 100, :answer => { }, :user_id => users(:user1).username
    assert_response :missing
  end
  
  def test_user_should_not_update_other_answer
    sign_in users(:user1)
    put :update, :id => 5, :answer => { }, :user_id => users(:user2).username
    assert_response :forbidden
  end
  
  def test_user_should_not_update_answer_without_body
    sign_in users(:user1)
    put :update, :id => 3, :answer => {:body => nil}, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_librarian_should_update_other_answer
    sign_in users(:librarian1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).username
  #  assert_redirected_to answer_url(assigns(:answer))
    assert_redirected_to answer_url(assigns(:answer))
  end
  
  def test_guest_should_not_destroy_answer
    assert_no_difference('Answer.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_answer
    sign_in users(:user1)
    assert_difference('Answer.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to question_answers_url(assigns(:answer).question)
  end

  def test_user_should_not_destroy_other_answer
    sign_in users(:user1)
    assert_no_difference('Answer.count') do
      delete :destroy, :id => 5, :user_id => users(:user2).username
    end
    
    assert_response :forbidden
  end

  #def test_everyone_should_not_destroy_missing_answer
  #  sign_in users(:admin)
  #  assert_no_difference('Answer.count') do
  #   delete :destroy, :id => 100, :user_id => users(:user1).username
  #  end
  #  
  #  assert_response :missing
  #end
end
