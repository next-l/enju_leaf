require 'test_helper'

class ItemHasUseRestrictionsControllerTest < ActionController::TestCase
    fixtures :item_has_use_restrictions, :use_restrictions, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:item_has_use_restrictions), []
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:item_has_use_restrictions), []
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:item_has_use_restrictions)
  end

  def test_librarian_should_get_index_with_item_id
    sign_in users(:librarian1)
    get :index, :item_id => 1
    assert_response :success
    assert_not_nil assigns(:item_has_use_restrictions)
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

  def test_guest_should_not_create_item_has_use_restriction
    assert_no_difference('ItemHasUseRestriction.count') do
      post :create, :item_has_use_restriction => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_item_has_use_restriction
    sign_in users(:user1)
    assert_no_difference('ItemHasUseRestriction.count') do
      post :create, :item_has_use_restriction => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_item_has_use_restriction_without_item_id
    sign_in users(:librarian1)
    assert_no_difference('ItemHasUseRestriction.count') do
      post :create, :item_has_use_restriction => {:use_restriction_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_not_create_item_has_use_restriction_without_use_restriction_id
    sign_in users(:librarian1)
    assert_no_difference('ItemHasUseRestriction.count') do
      post :create, :item_has_use_restriction => {:item_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_item_has_use_restriction
    sign_in users(:librarian1)
    assert_difference('ItemHasUseRestriction.count') do
      post :create, :item_has_use_restriction => {:item_id => 1, :use_restriction_id => 1}
    end

    assert_redirected_to item_has_use_restriction_url(assigns(:item_has_use_restriction))
  end

  def test_guest_should_not_show_item_has_use_restriction
    get :show, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_item_has_use_restriction
    sign_in users(:user1)
    get :show, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_item_has_use_restriction
    sign_in users(:librarian1)
    get :show, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_item_has_use_restriction
    put :update, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id, :item_has_use_restriction => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_item_has_use_restriction
    sign_in users(:user1)
    put :update, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id, :item_has_use_restriction => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_item_has_use_restriction_without_item_id
    sign_in users(:librarian1)
    put :update, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id, :item_has_use_restriction => {:item_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_item_has_use_restriction_without_use_restriction_id
    sign_in users(:librarian1)
    put :update, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id, :item_has_use_restriction => {:use_restriction_id => nil}
    assert_response :success
  end

  def test_librarian_should_update_item_has_use_restriction
    sign_in users(:librarian1)
    put :update, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id, :item_has_use_restriction => { }
    assert_redirected_to item_has_use_restriction_url(assigns(:item_has_use_restriction))
  end

  def test_guest_should_destroy_item_has_use_restriction
    assert_no_difference('ItemHasUseRestriction.count') do
      delete :destroy, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_item_has_use_restrictions
    sign_in users(:user1)
    assert_no_difference('ItemHasUseRestriction.count') do
      delete :destroy, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_item_has_use_restriction
    sign_in users(:librarian1)
    assert_difference('ItemHasUseRestriction.count', -1) do
      delete :destroy, :id => item_has_use_restrictions(:item_has_use_restriction_00001).id
    end

    assert_redirected_to item_has_use_restrictions_url
  end
end
