require 'test_helper'

class BookmarkStatHasManifestationsControllerTest < ActionController::TestCase
    fixtures :bookmark_stat_has_manifestations, :users, :manifestations, :bookmark_stats

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:bookmark_stat_has_manifestations)
  end

  test "user should not get index" do
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:bookmark_stat_has_manifestations)
  end

  test "librarian should get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:bookmark_stat_has_manifestations)
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

  test "guest should not create bookmark_stat_has_manifestation" do
    assert_no_difference('BookmarkStatHasManifestation.count') do
      post :create, :bookmark_stat_has_manifestation => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create bookmark_stat_has_manifestation" do
    sign_in users(:user1)
    assert_no_difference('BookmarkStatHasManifestation.count') do
      post :create, :bookmark_stat_has_manifestation => { }
    end

    assert_response :forbidden
  end

  test "librarian should create bookmark_stat_has_manifestation" do
    sign_in users(:librarian1)
    assert_difference('BookmarkStatHasManifestation.count') do
      post :create, :bookmark_stat_has_manifestation => {:bookmark_stat_id => 1, :manifestation_id => 3}
    end

    assert_redirected_to bookmark_stat_has_manifestation_path(assigns(:bookmark_stat_has_manifestation))
  end

  test "guest should not show bookmark_stat_has_manifestation" do
    get :show, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show bookmark_stat_has_manifestation" do
    sign_in users(:user1)
    get :show, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should show bookmark_stat_has_manifestation" do
    sign_in users(:librarian1)
    get :show, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should get edit" do
    get :edit, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get edit" do
    sign_in users(:user1)
    get :edit, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => bookmark_stat_has_manifestations(:one).id
    assert_response :success
  end

  test "guest should not update bookmark_stat_has_manifestation" do
    put :update, :id => bookmark_stat_has_manifestations(:one).id, :bookmark_stat_has_manifestation => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update bookmark_stat_has_manifestation" do
    sign_in users(:user1)
    put :update, :id => bookmark_stat_has_manifestations(:one).id, :bookmark_stat_has_manifestation => { }
    assert_response :forbidden
  end

  test "librarian should update bookmark_stat_has_manifestation" do
    sign_in users(:librarian1)
    put :update, :id => bookmark_stat_has_manifestations(:one).id, :bookmark_stat_has_manifestation => {:bookmark_stat_id => 1, :manifestation_id => 2}
    assert_redirected_to bookmark_stat_has_manifestation_path(assigns(:bookmark_stat_has_manifestation))
  end

  test "guest should not destroy bookmark_stat_has_manifestation" do
    assert_no_difference('BookmarkStatHasManifestation.count') do
      delete :destroy, :id => bookmark_stat_has_manifestations(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy bookmark_stat_has_manifestation" do
    sign_in users(:user1)
    assert_no_difference('BookmarkStatHasManifestation.count') do
      delete :destroy, :id => bookmark_stat_has_manifestations(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should destroy bookmark_stat_has_manifestation" do
    sign_in users(:librarian1)
    assert_difference('BookmarkStatHasManifestation.count', -1) do
      delete :destroy, :id => bookmark_stat_has_manifestations(:one).id
    end

    assert_redirected_to bookmark_stat_has_manifestations_path
  end
end
