# -*- encoding: utf-8 -*-
require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
    fixtures :bookmarks, :form_of_works, :content_types, :frequencies,
      :languages, :circulation_statuses, :users, :roles,
      :manifestations, :carrier_types, :tags, :taggings, :shelves, :items,
      :creates, :realizes, :produces, :owns, :patrons, :patron_types

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_equal assigns(:bookmarks), []
    assert_response :success
  end

  def test_user_should_get_other_public_index
    sign_in users(:user1)
    get :index, :user_id => users(:admin).username
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_user_should_not_get_other_private_index
    sign_in users(:user3)
    get :index, :user_id => users(:user1).username
    assert_response :forbidden
  end

  def test_guest_should_not_show_bookmark
    get :show, :id => 5
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_other_user_bookmark
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_show_my_bookmark
    sign_in users(:user1)
    get :show, :id => 3
    assert_response :success
  end
  
  def test_librarian_should_show_other_user_bookmark
    sign_in users(:librarian1)
    get :show, :id => 3
    assert_response :success
  end
  
  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit_other_user_bookmark
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_edit
    sign_in users(:user1)
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 3
    assert_response :success
  end
end
