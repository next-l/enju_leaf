require 'test_helper'

class UseRestrictionsControllerTest < ActionController::TestCase
  fixtures :use_restrictions, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:use_restrictions), []
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:use_restrictions), []
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:use_restrictions)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:use_restrictions)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
  end

  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  def test_admin_should_not_get_new
    sign_in users(:admin)
    get :new
    assert_response :forbidden
  end

  def test_guest_should_not_create_use_restriction
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_use_restriction
    sign_in users(:user1)
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_use_restriction
    sign_in users(:librarian1)
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => { }
    end

    assert_response :forbidden
  end

  def test_admin_should_not_create_use_restriction
    sign_in users(:admin)
    assert_no_difference('UseRestriction.count') do
      post :create, :use_restriction => {:name => 'test'}
    end

    assert_response :forbidden
  end

  def test_guest_should_not_show_use_restriction
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_use_restriction
    sign_in users(:user1)
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_use_restriction
    sign_in users(:librarian1)
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_admin_should_not_show_use_restriction
    sign_in users(:admin)
    get :show, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :forbidden
  end

  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => use_restrictions(:use_restriction_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_use_restriction
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_use_restriction
    sign_in users(:user1)
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_use_restriction
    sign_in users(:librarian1)
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_response :forbidden
  end

  def test_admin_should_not_update_use_restriction_without_name
    sign_in users(:admin)
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => {:name => ""}
    assert_response :success
  end

  def test_admin_should_update_use_restriction
    sign_in users(:admin)
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => { }
    assert_redirected_to use_restriction_url(assigns(:use_restriction))
  end

  test "admin should update use_restriction with position" do
    sign_in users(:admin)
    put :update, :id => use_restrictions(:use_restriction_00001).id, :use_restriction => {}, :position => 2
    assert_redirected_to use_restrictions_path
  end

  def test_guest_should_not_destroy_use_restriction
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_use_restriction
    sign_in users(:user1)
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_use_restriction
    sign_in users(:librarian1)
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_not_destroy_use_restriction
    sign_in users(:admin)
    assert_no_difference('UseRestriction.count') do
      delete :destroy, :id => use_restrictions(:use_restriction_00001).id
    end

    assert_response :forbidden
  end
end
