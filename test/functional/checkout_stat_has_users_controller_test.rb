require 'test_helper'

class CheckoutStatHasUsersControllerTest < ActionController::TestCase
    fixtures :checkout_stat_has_users, :users, :user_checkout_stats

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:checkout_stat_has_users), []
  end

  test "user should not get index" do
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:checkout_stat_has_users), []
  end

  test "librarian should get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:checkout_stat_has_users)
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

  test "should get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create checkout_stat_has_user" do
    assert_no_difference('CheckoutStatHasUser.count') do
      post :create, :checkout_stat_has_user => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create checkout_stat_has_user" do
    sign_in users(:user1)
    assert_no_difference('CheckoutStatHasUser.count') do
      post :create, :checkout_stat_has_user => { }
    end

    assert_response :forbidden
  end

  test "librarian should create checkout_stat_has_user" do
    sign_in users(:librarian1)
    assert_difference('CheckoutStatHasUser.count') do
      post :create, :checkout_stat_has_user => {:user_checkout_stat_id => 1, :user_id => 3}
    end

    assert_redirected_to checkout_stat_has_user_path(assigns(:checkout_stat_has_user))
  end

  test "guest should not show checkout_stat_has_user" do
    get :show, :id => checkout_stat_has_users(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show checkout_stat_has_user" do
    sign_in users(:user1)
    get :show, :id => checkout_stat_has_users(:one).id
    assert_response :forbidden
  end

  test "librarian should show checkout_stat_has_user" do
    sign_in users(:librarian1)
    get :show, :id => checkout_stat_has_users(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => checkout_stat_has_users(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => checkout_stat_has_users(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => checkout_stat_has_users(:one).id
    assert_response :success
  end

  test "guest should not update checkout_stat_has_user" do
    put :update, :id => checkout_stat_has_users(:one).id, :checkout_stat_has_user => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update checkout_stat_has_user" do
    sign_in users(:user1)
    put :update, :id => checkout_stat_has_users(:one).id, :checkout_stat_has_user => { }
    assert_response :forbidden
  end

  test "librarian should update checkout_stat_has_user" do
    sign_in users(:librarian1)
    put :update, :id => checkout_stat_has_users(:one).id, :checkout_stat_has_user => {:user_checkout_stat_id => 1, :user_id => 2}
    assert_redirected_to checkout_stat_has_user_path(assigns(:checkout_stat_has_user))
  end

  test "guest should not destroy checkout_stat_has_user" do
    assert_no_difference('CheckoutStatHasUser.count') do
      delete :destroy, :id => checkout_stat_has_users(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy checkout_stat_has_user" do
    sign_in users(:user1)
    assert_no_difference('CheckoutStatHasUser.count') do
      delete :destroy, :id => checkout_stat_has_users(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy checkout_stat_has_user" do
    sign_in users(:librarian1)
    assert_difference('CheckoutStatHasUser.count', -1) do
      delete :destroy, :id => checkout_stat_has_users(:one).id
    end

    assert_redirected_to checkout_stat_has_users_path
  end
end
