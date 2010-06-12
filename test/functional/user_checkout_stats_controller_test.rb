require 'test_helper'

class UserCheckoutStatsControllerTest < ActionController::TestCase
  fixtures :user_checkout_stats, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_checkout_stats)
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

  test "guest should not create user_checkout_stat" do
    assert_no_difference('UserCheckoutStat.count') do
      post :create, :user_checkout_stat => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not create user_checkout_stat" do
    sign_in users(:user1)
    assert_no_difference('UserCheckoutStat.count') do
      post :create, :user_checkout_stat => { }
    end

    assert_response :forbidden
  end

  test "librarian should create user_checkout_stat" do
    sign_in users(:librarian1)
    assert_difference('UserCheckoutStat.count') do
      post :create, :user_checkout_stat => {:start_date => Time.zone.now, :end_date => Time.zone.now.tomorrow}
    end

    assert_redirected_to user_checkout_stat_path(assigns(:user_checkout_stat))
  end

  test "guest should show user_checkout_stat" do
    get :show, :id => user_checkout_stats(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => user_checkout_stats(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => user_checkout_stats(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => user_checkout_stats(:one).id
    assert_response :success
  end

  test "guest should not update user_checkout_stat" do
    put :update, :id => user_checkout_stats(:one).id, :user_checkout_stat => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update user_checkout_stat" do
    sign_in users(:user1)
    put :update, :id => user_checkout_stats(:one).id, :user_checkout_stat => { }
    assert_response :forbidden
  end

  test "librarian should update user_checkout_stat" do
    sign_in users(:librarian1)
    put :update, :id => user_checkout_stats(:one).id, :user_checkout_stat => { }
    assert_redirected_to user_checkout_stat_path(assigns(:user_checkout_stat))
  end

  test "guest_should not destroy user_checkout_stat" do
    assert_no_difference('UserCheckoutStat.count') do
      delete :destroy, :id => user_checkout_stats(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy user_checkout_stat" do
    sign_in users(:user1)
    assert_no_difference('UserCheckoutStat.count') do
      delete :destroy, :id => user_checkout_stats(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy user_checkout_stat" do
    sign_in users(:librarian1)
    assert_difference('UserCheckoutStat.count', -1) do
      delete :destroy, :id => user_checkout_stats(:one).id
    end

    assert_redirected_to user_checkout_stats_path
  end
end
