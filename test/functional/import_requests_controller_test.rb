require 'test_helper'

class ImportRequestsControllerTest < ActionController::TestCase
  setup do
    @import_request = import_requests(:one)
  end

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get index" do
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  test "librarian should get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:import_requests)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create import_request" do
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create import_request" do
    sign_in users(:user1)
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes
    end

    assert_response :forbidden
  end

  test "librarian should create import_request" do
    sign_in users(:librarian1)
    assert_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes
    end

    assert_redirected_to new_import_request_path
  end

  test "guest should not show import_request" do
    get :show, :id => @import_request.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show import_request" do
    sign_in users(:user1)
    get :show, :id => @import_request.to_param
    assert_response :forbidden
  end

  test "librarian should show import_request" do
    sign_in users(:librarian1)
    get :show, :id => @import_request.to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => @import_request.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => @import_request.to_param
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => @import_request.to_param
    assert_response :success
  end

  test "guest should not update import_request" do
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_redirected_to new_user_session_url
  end

  test "user should not update import_request" do
    sign_in users(:user1)
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_response :forbidden
  end

  test "librarian should update import_request" do
    sign_in users(:librarian1)
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_redirected_to import_request_path(assigns(:import_request))
  end

  test "guest should not destroy import_request" do
    assert_no_difference('ImportRequest.count') do
      delete :destroy, :id => @import_request.to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy import_request" do
    sign_in users(:user1)
    assert_no_difference('ImportRequest.count') do
      delete :destroy, :id => @import_request.to_param
    end

    assert_response :forbidden
  end

  test "librarian should destroy import_request" do
    sign_in users(:librarian1)
    assert_difference('ImportRequest.count', -1) do
      delete :destroy, :id => @import_request.to_param
    end

    assert_redirected_to import_requests_path
  end
end
