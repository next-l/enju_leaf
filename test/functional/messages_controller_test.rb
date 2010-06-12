require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
    fixtures :users, :messages, :patrons, :patron_types

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :redirect
    assert_redirected_to user_messages_url(users(:user1))
  end
  
  def test_user_not_should_get_new_without_parent_id
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_user_should_not_get_new_with_invalid_parent_id
    sign_in users(:user1)
    get :new, :parent_id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_new_with_valid_parent_id
    sign_in users(:user1)
    get :new, :parent_id => 2
    assert_response :success
  end
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_user_should_show_own_message
    sign_in users(:user1)
    get :show, :user_id => users(:user1).username, :id => messages(:user2_to_user1_1)
    assert_response :success
  end

  def test_user_should_not_show_other_message
    sign_in users(:user1)
    get :show, :user_id => users(:user1).username, :id => messages(:user1_to_user2_1)
    assert_response :forbidden
  end
  
  def test_user_should_not_create_message_without_parent_id
    sign_in users(:user1)
    assert_no_difference('Message.count') do
      post :create, :message => {:recipient => 'user2', :subject => "test", :body => "test"}
    end
    assert_response :forbidden
  end
  
  def test_user_should_create_message_with_parent_id
    sign_in users(:user1)
    assert_difference('Message.count') do
      post :create, :message => {:recipient => 'user2', :subject => "test", :body => "test", :parent_id => 2}
    end
    assert_response :redirect
    assert_redirected_to user_messages_path(users(:user1))
  end
  
  def test_librarian_should_create_message_without_parent_id
    sign_in users(:librarian1)
    assert_difference('Message.count') do
      post :create, :message => {:recipient => 'user2', :subject => "test", :body => "test", :parent_id => 2}
    end
    assert_response :redirect
    assert_redirected_to user_messages_path(users(:librarian1))
  end
  
  def test_user_should_not_update_own_message
    sign_in users(:user1)
    put :update, :id => 2, :message => { }
    assert_response :forbidden
  end

  def test_user_should_not_update_other_message
    sign_in users(:user1)
    put :update, :id => 2, :message => { }
    assert_response :forbidden
  end

  def test_user_should_destroy_own_message
    sign_in users(:user1)
    assert_difference('users(:user1).received_messages.unread.count', -1) do
      delete :destroy, :id => 2
    end
    assert_response :redirect
    assert_redirected_to user_messages_path(users(:user1))
  end
  
  def test_user_should_not_destroy_other_message
    sign_in users(:user1)
    assert_no_difference('users(:user1).received_messages.unread.count') do
      delete :destroy, :id => 1
    end
    assert_response :forbidden
  end
  
end
