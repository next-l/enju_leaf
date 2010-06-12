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

  test "librarian should not get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  test "admin should get new" do
    sign_in users(:admin)
    get :new
    assert_response :success
  end

  test "guest should not create user_has_role" do
    assert_no_difference('UserHasRole.count') do
      post :create, :user_has_role => @user_has_role.attributes
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create user_has_role" do
    sign_in users(:user1)
    assert_no_difference('UserHasRole.count') do
      post :create, :user_has_role => @user_has_role.attributes
    end

    assert_response :forbidden
  end

  test "librarian should not create user_has_role" do
    sign_in users(:librarian1)
    assert_no_difference('UserHasRole.count') do
      post :create, :user_has_role => @user_has_role.attributes
    end

    assert_response :forbidden
  end

  test "admin should not create user_has_role" do
    sign_in users(:admin)
    assert_no_difference('UserHasRole.count') do
      post :create, :user_has_role => @user_has_role.attributes
    end

    assert_response :success
    #assert_redirected_to user_has_role_path(assigns(:user_has_role))
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

  test "guest should not get edit" do
    get :edit, :id => @user_has_role.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => @user_has_role.to_param
    assert_response :forbidden
  end

  test "librarian should not get edit" do
    sign_in users(:librarian1)
    get :edit, :id => @user_has_role.to_param
    assert_response :forbidden
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get :edit, :id => @user_has_role.to_param
    assert_response :success
  end

  test "guest should not update user_has_role" do
    put :update, :id => @user_has_role.to_param, :user_has_role => @user_has_role.attributes
    assert_redirected_to new_user_session_url
  end

  test "user should not update user_has_role" do
    sign_in users(:user1)
    put :update, :id => @user_has_role.to_param, :user_has_role => @user_has_role.attributes
    assert_response :forbidden
  end

  test "librarian should not update user_has_role" do
    sign_in users(:librarian1)
    put :update, :id => @user_has_role.to_param, :user_has_role => @user_has_role.attributes
    assert_response :forbidden
  end

  test "admin should update user_has_role" do
    sign_in users(:admin)
    put :update, :id => @user_has_role.to_param, :user_has_role => @user_has_role.attributes
    assert_redirected_to user_has_role_path(assigns(:user_has_role))
  end

  test "guest should not destroy user_has_role" do
    assert_no_difference('UserHasRole.count') do
      delete :destroy, :id => @user_has_role.to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy user_has_role" do
    sign_in users(:user1)
    assert_no_difference('UserHasRole.count') do
      delete :destroy, :id => @user_has_role.to_param
    end

    assert_response :forbidden
  end

  test "librarian should not destroy user_has_role" do
    sign_in users(:librarian1)
    assert_no_difference('UserHasRole.count') do
      delete :destroy, :id => @user_has_role.to_param
    end

    assert_response :forbidden
  end

  test "admin should destroy user_has_role" do
    sign_in users(:admin)
    assert_difference('UserHasRole.count', -1) do
      delete :destroy, :id => @user_has_role.to_param
    end

    assert_redirected_to user_has_roles_path
  end
end
