require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
    fixtures :users, :messages, :patrons, :patron_types

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
  
  def test_librarian_should_create_message_without_parent_id
    sign_in users(:librarian1)
    assert_difference('Message.count') do
      post :create, :message => {:recipient => 'user2', :subject => "test", :body => "test", :parent_id => 2}
    end
    assert_response :redirect
    assert_redirected_to messages_url
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
end
