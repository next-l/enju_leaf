require 'test_helper'

class LendingPoliciesControllerTest < ActionController::TestCase
    fixtures :lending_policies, :users, :items, :user_groups

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lending_policies)
  end

  test "guest should not get new" do
    get :new
    assert_redirected_to new_user_session_url
  end

  test "guest should not create lending_policy" do
    assert_no_difference('LendingPolicy.count') do
      post :create, :lending_policy => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create lending_policy" do
    sign_in users(:user1)
    assert_no_difference('LendingPolicy.count') do
      post :create, :lending_policy => { }
    end

    assert_response :forbidden
  end

  test "librarian should not create lending_policy" do
    sign_in users(:librarian1)
    assert_no_difference('LendingPolicy.count') do
      post :create, :lending_policy => { }
    end

    assert_response :forbidden
  end

  test "administrator should not create lending_policy" do
    sign_in users(:admin)
    assert_difference('LendingPolicy.count') do
      post :create, :lending_policy => {:item_id => 2, :user_group_id => 1}
    end

    assert_redirected_to lending_policy_url(assigns(:lending_policy))
  end

  test "guest should show lending_policy" do
    get :show, :id => lending_policies(:lending_policy_00001).to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => lending_policies(:lending_policy_00001).to_param
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => lending_policies(:lending_policy_00001).to_param
    assert_response :forbidden
  end

  test "librarian should not get edit" do
    sign_in users(:librarian1)
    get :edit, :id => lending_policies(:lending_policy_00001).to_param
    assert_response :forbidden
  end

  test "administrator should not get edit" do
    sign_in users(:admin)
    get :edit, :id => lending_policies(:lending_policy_00001).to_param
    assert_response :success
  end

  test "guest should not update lending_policy" do
    put :update, :id => lending_policies(:lending_policy_00001).to_param, :lending_policy => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update lending_policy" do
    sign_in users(:user1)
    put :update, :id => lending_policies(:lending_policy_00001).to_param, :lending_policy => { }
    assert_response :forbidden
  end

  test "librarian should not update lending_policy" do
    sign_in users(:librarian1)
    put :update, :id => lending_policies(:lending_policy_00001).to_param, :lending_policy => { }
    assert_response :forbidden
  end

  test "administrator should not update lending_policy" do
    sign_in users(:admin)
    put :update, :id => lending_policies(:lending_policy_00001).to_param, :lending_policy => { }
    assert_redirected_to lending_policy_url(assigns(:lending_policy))
  end

  test "guest should not destroy lending_policy" do
    assert_no_difference('LendingPolicy.count') do
      delete :destroy, :id => lending_policies(:lending_policy_00001).to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy lending_policy" do
    sign_in users(:user1)
    assert_no_difference('LendingPolicy.count') do
      delete :destroy, :id => lending_policies(:lending_policy_00001).to_param
    end

    assert_response :forbidden
  end

  test "librarian should not destroy lending_policy" do
    sign_in users(:librarian1)
    assert_no_difference('LendingPolicy.count') do
      delete :destroy, :id => lending_policies(:lending_policy_00001).to_param
    end

    assert_response :forbidden
  end

  test "admin should not destroy lending_policy" do
    sign_in users(:admin)
    assert_difference('LendingPolicy.count', -1) do
      delete :destroy, :id => lending_policies(:lending_policy_00001).to_param
    end

    assert_redirected_to lending_policies_url
  end
end
