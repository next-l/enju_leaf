require 'test_helper'

class ManifestationReserveStatsControllerTest < ActionController::TestCase
  fixtures :manifestation_reserve_stats, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_reserve_stats)
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

  test "guest should not create manifestation_reserve_stat" do
    assert_no_difference('ManifestationReserveStat.count') do
      post :create, :manifestation_reserve_stat => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not create manifestation_reserve_stat" do
    sign_in users(:user1)
    assert_no_difference('ManifestationReserveStat.count') do
      post :create, :manifestation_reserve_stat => { }
    end

    assert_response :forbidden
  end

  test "librarian should create manifestation_reserve_stat" do
    sign_in users(:librarian1)
    assert_difference('ManifestationReserveStat.count') do
      post :create, :manifestation_reserve_stat => {:start_date => Time.zone.now, :end_date => Time.zone.now.tomorrow}
    end

    assert_redirected_to manifestation_reserve_stat_path(assigns(:manifestation_reserve_stat))
  end

  test "guest should show manifestation_reserve_stat" do
    get :show, :id => manifestation_reserve_stats(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => manifestation_reserve_stats(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => manifestation_reserve_stats(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => manifestation_reserve_stats(:one).id
    assert_response :success
  end

  test "guest should not update manifestation_reserve_stat" do
    put :update, :id => manifestation_reserve_stats(:one).id, :manifestation_reserve_stat => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update manifestation_reserve_stat" do
    sign_in users(:user1)
    put :update, :id => manifestation_reserve_stats(:one).id, :manifestation_reserve_stat => { }
    assert_response :forbidden
  end

  test "librarian should update manifestation_reserve_stat" do
    sign_in users(:librarian1)
    put :update, :id => manifestation_reserve_stats(:one).id, :manifestation_reserve_stat => { }
    assert_redirected_to manifestation_reserve_stat_path(assigns(:manifestation_reserve_stat))
  end

  test "guest_should not destroy manifestation_reserve_stat" do
    assert_no_difference('ManifestationReserveStat.count') do
      delete :destroy, :id => manifestation_reserve_stats(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy manifestation_reserve_stat" do
    sign_in users(:user1)
    assert_no_difference('ManifestationReserveStat.count') do
      delete :destroy, :id => manifestation_reserve_stats(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy manifestation_reserve_stat" do
    sign_in users(:librarian1)
    assert_difference('ManifestationReserveStat.count', -1) do
      delete :destroy, :id => manifestation_reserve_stats(:one).id
    end

    assert_redirected_to manifestation_reserve_stats_path
  end
end
