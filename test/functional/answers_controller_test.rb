require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
    fixtures :answers, :questions, :languages, :patrons, :patron_types,
      :user_groups, :users, :roles, :library_groups, :libraries, :countries,
      :manifestations, :items

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_get_other_index_without_question_id
    get :index, :user_id => users(:user1).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_get_other_index_without_user_id
    get :index, :question_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_index_without_user_id
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_without_user_id
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username
    assert_response :forbidden
  end

  def test_librarian_should_get_index_without_user_id
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index_without_question_id
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_get_my_index_feed
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username, :format => 'rss'
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_if_question_is_not_shared
    sign_in users(:user1)
    get :index, :user_id => users(:librarian1).username, :question_id => 2
    assert_response :forbidden
  end

  def test_user_should_get_other_index_if_question_is_shared
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username, :question_id => 5
    assert_response :success
    assert assigns(:answers)
  end

  def test_user_should_not_get_other_index_feed_if_question_is_not_shared
    sign_in users(:user1)
    get :index, :user_id => users(:librarian1).username, :question_id => 2, :format => 'rss'
    #assert_response :forbidden
    assert_response :not_acceptable
  end

  def test_user_should_get_other_index_feed_if_question_is_shared
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username, :question_id => 5, :format => 'rss'
    assert_response :success
    assert assigns(:answers)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_new_without_question_id
    sign_in users(:user1)
    get :new
    assert_response :redirect
    assert_redirected_to questions_url
  end
  
  def test_user_should_get_new
    sign_in users(:user1)
    get :new, :user_id => users(:user2).username, :question_id => 1
    assert_response :success
  end
  
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
    
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.username, assigns(:answer).question, assigns(:answer))
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
    
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.username, assigns(:answer).question, assigns(:answer))
  end

  def test_guest_should_show_public_answer
    get :show, :id => 1, :question_id => 1
    assert_response :success
  end

  def test_guest_should_not_show_private_answer
    get :show, :id => 4, :question_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_answer_without_user_id
    sign_in users(:user1)
    get :show, :id => 1, :question_id => 1
    assert_response :success
  end

  def test_user_should_show_public_answer_without_question_id
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_show_my_answer
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_not_show_other_public_answer_if_queston_is_private
    sign_in users(:user1)
    get :show, :id => 5, :user_id => users(:user2).username
    assert_response :forbidden
  end

  def test_user_should_not_show_private_answer
    sign_in users(:user1)
    get :show, :id => 4, :user_id => users(:user1).username
    assert_response :forbidden
  end

  def test_user_should_not_show_missing_answer
    sign_in users(:user1)
    get :show, :id => 100, :user_id => users(:user1).username, :question_id => 1
    assert_response :missing
  end

  def test_user_should_not_show_answer_with_other_user_id
    sign_in users(:user1)
    get :show, :id => 5, :user_id => users(:user2).username, :question_id => 2
    assert_response :forbidden
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_my_edit_without_user_id
    sign_in users(:user1)
    get :edit, :id => 3, :question_id => 1
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit_without_user_id
    sign_in users(:user1)
    get :edit, :id => 4, :question_id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_edit_without_question_id
    sign_in users(:user1)
    get :edit, :id => 3 , :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_user_should_not_get_missing_edit
    sign_in users(:user1)
    get :edit, :id => 100, :user_id => users(:user1).username, :question_id => 1
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username, :question_id => 1
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    sign_in users(:user1)
    get :edit, :id => 5, :user_id => users(:user2).username, :question_id => 2
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_answer
    put :update, :id => 1, :answer => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_answer
    sign_in users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).username
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.username, assigns(:answer).question, assigns(:answer))
  end
  
  def test_user_should_update_my_answer_with_question_id
    sign_in users(:user1)
    put :update, :id => 3, :answer => { }, :user_id => users(:user1).username, :question_id => 1
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.username, assigns(:answer).question, assigns(:answer))
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
    assert_redirected_to user_question_answer_url(assigns(:answer).question.user.username, assigns(:answer).question, assigns(:answer))
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
    
    assert_redirected_to user_question_answers_url(assigns(:answer).question.user.username, assigns(:answer).question)
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
