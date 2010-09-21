require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  fixtures :questions, :users, :user_groups, :roles, :patrons, :libraries

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_get_solved_question_index
    get :index, :solved => 'true'
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_get_unsolved_question_index
    get :index, :solved => 'false'
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_get_index_with_query
    get :index, :query => 'Yahoo'
    assert_response :success
    assert assigns(:questions)
    assert assigns(:crd_results)
  end

  def test_guest_should_render_crd_xml_template
    get :index, :query => 'Yahoo', :mode => 'crd', :format => 'xml'
    assert_response :success
    assert_template 'questions/index_crd'
  end

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_my_index_feed
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_index_without_user_id
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username
    assert_response :success
    assert assigns(:questions)
  end

  def test_user_should_get_other_index_feed
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_without_user_id
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:questions)
  end

  def test_librarian_should_get_index_feed_without_user_id
    sign_in users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:questions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_new
    sign_in users(:user1)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_question
    assert_no_difference('Question.count') do
      post :create, :question => { }
    end
    
    assert_redirected_to new_user_session_url
  end


  def test_user_should_not_create_question_without_body
    sign_in users(:user1)
    assert_no_difference('Question.count') do
      post :create, :question => { }
    end
    
    assert_response :success
  end

  def test_user_should_create_question_with_body
    sign_in users(:user1)
    assert_difference('Question.count') do
      post :create, :question => {:body => 'test'}
    end
    
    assert_redirected_to user_question_url(users(:user1).username, assigns(:question))
  end

  def test_guest_should_show_question
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_show_crd_xml
    get :show, :id => 1, :mode => 'crd', :format => :xml
    assert_response :success
    assert_template 'questions/show_crd'
  end

  def test_user_should_show_question_without_user_id
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_other_question
    sign_in users(:user1)
    get :show, :id => 5, :user_id => users(:user2).username
    assert_response :success
  end

  def test_user_should_not_show_missing_question
    sign_in users(:user1)
    get :show, :id => 100, :user_id => users(:user2).username
    assert_response :missing
  end

  def test_user_should_show_my_question_with_user_id
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_show_question_with_other_user_id
    sign_in users(:user1)
    get :show, :id => 5, :user_id => users(:user2).username
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit_other_question
    sign_in users(:user1)
    get :edit, :id => 5
    assert_response :forbidden
  end
  
  def test_user_should_not_get_missing_edit
    sign_in users(:user1)
    get :edit, :id => 100, :user_id => users(:user1).username
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    sign_in users(:user1)
    get :edit, :id => 5, :user_id => users(:user2).username
    assert_response :forbidden
  end
  
  def test_user_should_not_update_question_without_username
    put :update, :id => 1, :question => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_question
    sign_in users(:user1)
    put :update, :id => 3, :question => { }, :user_id => users(:user1).username
    assert_redirected_to user_question_url(users(:user1).username, assigns(:question))
  end
  
  def test_user_should_not_update_missing_question
    sign_in users(:user1)
    put :update, :id => 100, :question => { }, :user_id => users(:user1).username
    assert_response :missing
  end
  
  def test_user_should_not_update_other_question
    sign_in users(:user1)
    put :update, :id => 5, :question => { }, :user_id => users(:user2).username
    assert_response :forbidden
  end
  
  def test_user_should_not_update_without_body
    sign_in users(:user1)
    put :update, :id => 3, :question => {:body => ""}, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_guest_should_not_destroy_question
    assert_no_difference('Question.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_question
    sign_in users(:user1)
    assert_difference('Question.count', -1) do
      delete :destroy, :id => 3
    end
    
    assert_redirected_to user_questions_url(assigns(:question).user.username)
  end

  def test_user_should_not_destroy_other_question
    sign_in users(:user1)
    assert_no_difference('Question.count') do
      delete :destroy, :id => 5, :user_id => users(:user2).username
    end
    
    assert_response :forbidden
  end

  def test_user_should_not_destroy_missing_question
    sign_in users(:user1)
    assert_no_difference('Question.count') do
      delete :destroy, :id => 100, :user_id => users(:user1).username
    end
    
    assert_response :missing
  end
end
