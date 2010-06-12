require 'test_helper'

class MessageRequestsControllerTest < ActionController::TestCase
    fixtures :message_requests, :users, :user_groups, :patrons, :message_templates

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:message_requests)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  def test_guest_should_not_create_message_request
    assert_no_difference('MessageRequest.count') do
      post :create, :message_request => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_message_request
    sign_in users(:user1)
    assert_no_difference('MessageRequest.count') do
      post :create, :message_request => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_message_request
    sign_in users(:librarian1)
    assert_no_difference('MessageRequest.count') do
      post :create, :message_request => {:sender_id => 1, :receiver_id => 2, :message_template_id => 1}
    end

    #assert_redirected_to message_request_path(assigns(:message_request))
    assert_response :forbidden
  end

  def test_guest_should_not_show_message_request
    get :show, :id => message_requests(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_message_request
    sign_in users(:user1)
    get :show, :id => message_requests(:one).id
    assert_response :forbidden
  end

  def test_librarian_should_show_message_request
    sign_in users(:librarian1)
    get :show, :id => message_requests(:one).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => message_requests(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => message_requests(:one).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => message_requests(:one).id
    assert_response :success
  end

  def test_guest_should_not_update_message_request
    put :update, :id => message_requests(:one).id, :message_request => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_message_request
    sign_in users(:user1)
    put :update, :id => message_requests(:one).id, :message_request => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_message_request
    sign_in users(:librarian1)
    put :update, :id => message_requests(:one).id, :message_request => { }
    assert_redirected_to message_request_path(assigns(:message_request))
  end

  def test_guest_should_not_destroy_message_request
    assert_no_difference('MessageRequest.count', -1) do
      delete :destroy, :id => message_requests(:one).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_message_request
    sign_in users(:user1)
    assert_no_difference('MessageRequest.count', -1) do
      delete :destroy, :id => message_requests(:one).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_message_request
    sign_in users(:librarian1)
    assert_difference('MessageRequest.count', -1) do
      delete :destroy, :id => message_requests(:one).id
    end

    assert_redirected_to message_requests_path
  end
end
