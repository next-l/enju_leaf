# -*- encoding: utf-8 -*-
require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
    fixtures :bookmarks, :form_of_works, :content_types, :frequencies,
      :languages, :circulation_statuses, :users, :roles,
      :manifestations, :carrier_types, :tags, :taggings, :shelves, :items,
      :creates, :realizes, :produces, :owns, :patrons, :patron_types

  def test_guest_should_not_get_index
    get :index
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index_without_user_id
    sign_in users(:user1)
    get :index
    assert_response :redirect
    assert_redirected_to user_bookmarks_url(users(:user1).username)
  end

  def test_librarian_should_get_index_without_user_id
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_admin_should_get_index_without_user_id
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_user_should_get_other_public_index
    sign_in users(:user1)
    get :index, :user_id => users(:admin).username
    assert_response :success
    assert assigns(:bookmarks)
  end

  def test_user_should_not_get_other_private_index
    sign_in users(:user2)
    get :index, :user_id => users(:user1).username
    assert_response :forbidden
    assert_equal assigns(:bookmarks), []
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new_without_user_id
    sign_in users(:user1)
    get :new
    #assert_response :forbidden
    assert_response :missing
  end
  
  def test_user_should_not_get_new_with_other_user_id
    sign_in users(:user1)
    get :new, :user_id => users(:admin).username
    assert_response :forbidden
  end
  
  def test_user_should_not_get_my_new_without_url
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username
    assert_response :redirect
    assert_redirected_to user_bookmarks_url(users(:user1))
  end
  
  def test_user_should_not_get_new_with_already_bookmarked_url
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username, :bookmark => {:url => 'http://www.slis.keio.ac.jp/'}
    assert_response :redirect
    assert_equal I18n.t('bookmark.already_bookmarked'), flash[:notice]
    assert_redirected_to manifestation_url(assigns(:bookmark).get_manifestation)
  end
  
  def test_user_should_get_my_new_with_external_url
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username, :bookmark => {:title => 'example', :url => 'http://example.com'}
    assert_response :success
  end
  
  def test_user_should_get_my_new_with_internal_url
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username, :bookmark => {:url => "#{LibraryGroup.url}/manifestations/1"}
    assert_response :success
  end
  
  def test_guest_should_not_create_bookmark
    assert_no_difference('Bookmark.count') do
      post :create, :bookmark => {:title => 'example', :url => 'http://example.com'}
    end
    assert_redirected_to new_user_session_url
  end

  def test_user_should_create_bookmark
    sign_in users(:user1)
    assert_difference('Bookmark.count') do
      post :create, :bookmark => {:title => 'example', :url => 'http://example.com/'}, :user_id => users(:user1).username
    end
    
    assert_redirected_to bookmark_url(assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end

  def test_user_should_create_bookmark_with_local_url
    sign_in users(:user1)
    assert_difference('Bookmark.count') do
      post :create, :bookmark => {:title => 'example', :url => "#{LibraryGroup.url}manifestations/10"}
    end
    
    assert_redirected_to bookmark_url(assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end

  def test_user_should_not_create_other_users_bookmark
    sign_in users(:user1)
    old_bookmark_counts = users(:user2).bookmarks.count
    assert_no_difference('Bookmark.count') do
      post :create, :bookmark => {:user_id => users(:user2).id, :title => 'example', :url => 'http://example.com/'}
    end
    assert_equal old_bookmark_counts, users(:user2).bookmarks.count
    
    assert_response :forbidden
  end

  def test_user_should_create_bookmark_with_tag_list
    sign_in users(:user1)
    old_tag_count = Tag.count
    assert_difference('Bookmark.count') do
      post :create, :bookmark => {:tag_list => 'search', :title => 'example', :url => 'http://example.com/'}, :user_id => users(:user1).username
    end
    
    assert_equal ['search'], assigns(:bookmark).tag_list
    assert_equal 1, assigns(:bookmark).taggings.size
    assert_equal old_tag_count+1, Tag.count
    #assert_equal 1, assigns(:bookmark).manifestation.items.size
    assert_redirected_to bookmark_url(assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end

  def test_user_should_create_bookmark_with_tag_list_include_wide_space
    sign_in users(:user1)
    old_tag_count = Tag.count
    assert_difference('Bookmark.count') do
      post :create, :bookmark => {:tag_list => 'タグの　テスト', :title => 'example', :url => 'http://example.com/'}, :user_id => users(:user1).username
    end
    
    #assert_equal ['タグの', 'テスト'], assigns(:bookmark).tag_list
    #assert_nil assigns(:bookmark).manifestation.items.first.item_identifier
    #assert_equal 1, assigns(:bookmark).manifestation.items.size
    assert_equal old_tag_count+2, Tag.count
    assert_redirected_to bookmark_url(assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end

  def test_user_should_not_create_bookmark_without_url
    sign_in users(:user1)
    assert_no_difference('Bookmark.count') do
      post :create, :bookmark => {:title => 'test'}
    end
    
    assert_response :success
  end

  def test_user_should_not_create_bookmark_already_bookmarked
    sign_in users(:user1)
    assert_no_difference('Bookmark.count') do
      post :create, :bookmark => {:user_id => users(:user1).id, :url => 'http://www.slis.keio.ac.jp/'}, :user_id => users(:user1).username
    end
    
    assert_equal I18n.t('bookmark.already_bookmarked'), flash[:notice]
  end

  def test_guest_should_not_show_bookmark_without_user_id
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_show_bookmark_with_user_id
    get :show, :id => 5, :user_id => users(:user2).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_other_user_bookmark
    sign_in users(:user1)
    get :show, :id => 1, :user_id => users(:admin).username
    assert_response :forbidden
  end
  
  def test_user_should_show_my_bookmark
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_librarian_should_show_other_user_bookmark
    sign_in users(:librarian1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit_without_user_id
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_not_get_edit_other_user_bookmark
    sign_in users(:user1)
    get :edit, :id => 1, :user_id => users(:admin).username
    assert_response :forbidden
  end
  
  def test_user_should_get_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_librarian_should_get_edit_without_user
    sign_in users(:librarian1)
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_guest_should_not_update_bookmark
    put :update, :id => 1, :user_id => users(:admin).username, :bookmark => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_update_my_bookmark_without_user_id
    sign_in users(:user1)
    put :update, :id => 3, :bookmark => { }
    assert_response :redirect
    assert_redirected_to user_bookmark_url(users(:user1).username, assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end

  def test_user_should_not_update_other_user_bookmark
    sign_in users(:user1)
    put :update, :id => 1, :user_id => users(:admin).username, :bookmark => { }
    assert_response :forbidden
  end

  def test_user_should_not_update_missing_bookmark
    sign_in users(:user1)
    put :update, :id => 100, :user_id => users(:user1).username, :bookmark => { }
    assert_response :missing
  end

  def test_user_should_update_without_manifestation_id
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :bookmark => {:manifestation_id => nil}
    assert_response :redirect
    assert_redirected_to user_bookmark_url(users(:user1).username, assigns(:bookmark))
  end

  def test_user_should_update_bookmark
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :bookmark => { }
    assert_response :redirect
    assert_redirected_to user_bookmark_url(users(:user1).username, assigns(:bookmark))
    assigns(:bookmark).remove_from_index!
  end
  
  def test_user_should_add_tags_to_bookmark
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :bookmark => {:user_id => users(:user1).id, :tag_list => 'search', :title => 'test'}
    assert_redirected_to user_bookmark_url(users(:user1).username, assigns(:bookmark))
    assert_equal ['search'], assigns(:bookmark).tag_list
    assigns(:bookmark).remove_from_index!
  end
  
  def test_user_should_remove_tags_from_bookmark
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :bookmark => {:user_id => users(:user1).id, :tag_list => nil, :title => 'test'}
    assert_redirected_to user_bookmark_url(users(:user1).username, assigns(:bookmark))
    assert_equal [], assigns(:bookmark).tag_list
    assigns(:bookmark).remove_from_index!
  end
  
  def test_guest_should_not_destroy_bookmark
    assert_no_difference('Bookmark.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_destroy_my_bookmark
    sign_in users(:user1)
    assert_difference('Bookmark.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to user_bookmarks_url(users(:user1).username)
  end

  def test_user_should_not_destroy_other_bookmark
    sign_in users(:user1)
    assert_no_difference('Bookmark.count', -1) do
      delete :destroy, :id => 1, :user_id => users(:admin).username
    end
    
    assert_response :forbidden
  end
end
