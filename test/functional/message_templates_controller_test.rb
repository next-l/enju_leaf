require 'test_helper'

class MessageTemplatesControllerTest < ActionController::TestCase
    fixtures :message_templates, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:message_templates)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:message_templates)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:message_templates)
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

  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_message_template
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_message_template_without_status
    sign_in users(:admin)
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => {:title => 'test4', :body => 'test'}
    end

    assert_response :success
  end

  def test_everyone_should_not_create_message_template_without_title
    sign_in users(:admin)
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => {:status => 'test4', :body => 'test'}
    end

    assert_response :success
  end

  def test_everyone_should_not_create_message_template_without_body
    sign_in users(:admin)
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => {:status => 'test4', :title => 'test'}
    end

    assert_response :success
  end

  def test_everyone_should_not_create_message_template_which_has_same_status
    sign_in users(:admin)
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => {:status => 'reservation_accepted', :body => 'test', :title => 'test'}
    end

    assert_response :success
  end

  def test_user_should_not_create_message_template
    sign_in users(:user1)
    assert_no_difference('MessageTemplate.count') do
      post :create, :message_template => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_message_template
    sign_in users(:librarian1)
    assert_difference('MessageTemplate.count') do
      post :create, :message_template => {:status => 'test4', :title => 'example', :body => 'example'}
    end

    assert_redirected_to message_template_url(assigns(:message_template))
  end

  def test_guest_should_not_show_message_template
    get :show, :id => message_templates(:message_template_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_message_template
    sign_in users(:user1)
    get :show, :id => message_templates(:message_template_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_message_template
    sign_in users(:librarian1)
    get :show, :id => message_templates(:message_template_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => message_templates(:message_template_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => message_templates(:message_template_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => message_templates(:message_template_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_message_template
    put :update, :id => message_templates(:message_template_00001).id, :message_template => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_message_template
    sign_in users(:user1)
    put :update, :id => message_templates(:message_template_00001).id, :message_template => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_message_template
    sign_in users(:librarian1)
    put :update, :id => message_templates(:message_template_00001).id, :message_template => { }
    assert_redirected_to message_template_url(assigns(:message_template))
  end

  def test_guest_should_not_destroy_message_template
    assert_no_difference('MessageTemplate.count') do
      delete :destroy, :id => message_templates(:message_template_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_message_template
    sign_in users(:user1)
    assert_no_difference('MessageTemplate.count') do
      delete :destroy, :id => message_templates(:message_template_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_message_template
    sign_in users(:librarian1)
    assert_difference('MessageTemplate.count', -1) do
      delete :destroy, :id => message_templates(:message_template_00001).id
    end

    assert_redirected_to message_templates_url
  end
end
