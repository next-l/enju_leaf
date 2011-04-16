require 'test_helper'

class UserHasRolesControllerTest < ActionController::TestCase
  setup do
    @user_has_role = user_has_roles(:user1)
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

  test "librarian should not get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :forbidden
  end

  test "admin should get index" do
    sign_in users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:user_has_roles)
  end

  test "guest should not show user_has_role" do
    get :show, :id => @user_has_role.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show user_has_role" do
    sign_in users(:user1)
    get :show, :id => @user_has_role.to_param
    assert_response :forbidden
  end

  test "librarian should show user_has_role" do
    sign_in users(:librarian1)
    get :show, :id => @user_has_role.to_param
    assert_response :forbidden
  end

  test "admin should show user_has_role" do
    sign_in users(:admin)
    get :show, :id => @user_has_role.to_param
    assert_response :success
  end
end
