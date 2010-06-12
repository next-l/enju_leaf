require 'test_helper'

class RequestTypesControllerTest < ActionController::TestCase
  fixtures :request_types, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:request_types)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:request_types)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:request_types)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:request_types)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
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

  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_request_type
    assert_no_difference('RequestType.count') do
      post :create, :request_type => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_request_type
    sign_in users(:user1)
    assert_no_difference('RequestType.count') do
      post :create, :request_type => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_request_type
    sign_in users(:librarian1)
    assert_no_difference('RequestType.count') do
      post :create, :request_type => { }
    end

    assert_response :forbidden
  end

  def test_admin_should_not_create_request_type_without_name
    sign_in users(:admin)
    assert_no_difference('RequestType.count') do
      post :create, :request_type => { }
    end

    assert_response :success
  end

  def test_admin_should_create_request_type
    sign_in users(:admin)
    assert_difference('RequestType.count') do
      post :create, :request_type => {:name => 'test'}
    end

    assert_redirected_to request_type_url(assigns(:request_type))
  end

  def test_guest_should_not_show_request_type
    get :show, :id => request_types(:request_type_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_request_type
    sign_in users(:user1)
    get :show, :id => request_types(:request_type_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_request_type
    sign_in users(:librarian1)
    get :show, :id => request_types(:request_type_00001).id
    assert_response :success
  end

  def test_admin_should_not_show_request_type
    sign_in users(:admin)
    get :show, :id => request_types(:request_type_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => request_types(:request_type_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => request_types(:request_type_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => request_types(:request_type_00001).id
    assert_response :forbidden
  end

  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => request_types(:request_type_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_request_type
    put :update, :id => request_types(:request_type_00001).id, :request_type => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_request_type
    sign_in users(:user1)
    put :update, :id => request_types(:request_type_00001).id, :request_type => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_request_type
    sign_in users(:librarian1)
    put :update, :id => request_types(:request_type_00001).id, :request_type => { }
    assert_response :forbidden
  end

  def test_admin_should_not_update_request_type_without_name
    sign_in users(:admin)
    put :update, :id => request_types(:request_type_00001).id, :request_type => {:name => ""}
    assert_response :success
  end

  def test_admin_should_update_request_type
    sign_in users(:admin)
    put :update, :id => request_types(:request_type_00001).id, :request_type => { }
    assert_redirected_to request_type_url(assigns(:request_type))
  end

  def test_guest_should_not_destroy_request_type
    assert_no_difference('RequestType.count') do
      delete :destroy, :id => request_types(:request_type_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_request_type
    sign_in users(:user1)
    assert_no_difference('RequestType.count') do
      delete :destroy, :id => request_types(:request_type_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_request_type
    sign_in users(:librarian1)
    assert_no_difference('RequestType.count') do
      delete :destroy, :id => request_types(:request_type_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_destroy_request_type
    sign_in users(:admin)
    assert_difference('RequestType.count', -1) do
      delete :destroy, :id => request_types(:request_type_00001).id
    end

    assert_redirected_to request_types_url
  end
end
