require 'test_helper'

class PatronMergesControllerTest < ActionController::TestCase
    fixtures :patron_merges, :patrons, :patron_merge_lists, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:patron_merges)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:patron_merges)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_merges)
  end

  def test_librarian_should_get_index_with_patron_id
    sign_in users(:librarian1)
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert_not_nil assigns(:patron_merges)
  end

  def test_librarian_should_get_index_with_patron_merge_list_id
    sign_in users(:librarian1)
    get :index, :patron_merge_list_id => 1
    assert_response :success
    assert assigns(:patron_merge_list)
    assert_not_nil assigns(:patron_merges)
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

  def test_guest_should_not_create_patron_merge
    assert_no_difference('PatronMerge.count') do
      post :create, :patron_merge => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_patron_merge
    sign_in users(:user1)
    assert_no_difference('PatronMerge.count') do
      post :create, :patron_merge => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_patron_merge_without_patron_id
    sign_in users(:librarian1)
    assert_no_difference('PatronMerge.count') do
      post :create, :patron_merge => {:patron_merge_list_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_patron_merge_without_patron_merge_list_id
    sign_in users(:librarian1)
    assert_no_difference('PatronMerge.count') do
      post :create, :patron_merge => {:patron_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_patron_merge
    sign_in users(:librarian1)
    assert_difference('PatronMerge.count') do
      post :create, :patron_merge => {:patron_id => 1, :patron_merge_list_id => 1}
    end

    assert_redirected_to patron_merge_url(assigns(:patron_merge))
  end

  def test_guest_should_not_show_patron_merge
    get :show, :id => patron_merges(:patron_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_patron_merge
    sign_in users(:user1)
    get :show, :id => patron_merges(:patron_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_show_patron_merge
    sign_in users(:librarian1)
    get :show, :id => patron_merges(:patron_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => patron_merges(:patron_merge_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => patron_merges(:patron_merge_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => patron_merges(:patron_merge_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_patron_merge
    put :update, :id => patron_merges(:patron_merge_00001).id, :patron_merge => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_patron_merge
    sign_in users(:user1)
    put :update, :id => patron_merges(:patron_merge_00001).id, :patron_merge => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_patron_merge_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => patron_merges(:patron_merge_00001).id, :patron_merge => {:patron_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_patron_merge_without_patron_merge_list_id
    sign_in users(:librarian1)
    put :update, :id => patron_merges(:patron_merge_00001).id, :patron_merge => {:patron_merge_list_id => nil}
    assert_response :success
  end

  def test_librarian_should_update_patron_merge
    sign_in users(:librarian1)
    put :update, :id => patron_merges(:patron_merge_00001).id, :patron_merge => { }
    assert_redirected_to patron_merge_url(assigns(:patron_merge))
  end

  def test_guest_should_not_destroy_patron_merge
    assert_no_difference('PatronMerge.count') do
      delete :destroy, :id => patron_merges(:patron_merge_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_patron_merge
    sign_in users(:user1)
    assert_no_difference('PatronMerge.count') do
      delete :destroy, :id => patron_merges(:patron_merge_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_patron_merge
    sign_in users(:librarian1)
    assert_difference('PatronMerge.count', -1) do
      delete :destroy, :id => patron_merges(:patron_merge_00001).id
    end

    assert_redirected_to patron_merges_url
  end
end
