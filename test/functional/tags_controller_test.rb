require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  fixtures :tags, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:tags)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:tags)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:tags)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:tags)
  end

  def test_guest_should_show_tag
    get :show, :id => 'next-l'
    assert_response :success
  end

  def test_user_should_show_tag
    sign_in users(:user1)
    get :show, :id => 'next-l'
    assert_response :success
  end

  def test_librarian_should_show_tag
    sign_in users(:librarian1)
    get :show, :id => 'next-l'
    assert_response :success
  end

  def test_admin_should_show_tag
    sign_in users(:admin)
    get :show, :id => 'next-l'
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 'next-l'
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 'next-l'
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 'next-l'
    assert_response :success
  end
  
  #def test_guest_should_not_update_tag
  #  put :update, :id => 'next-l', :tag => { }
  #  assert_redirected_to new_user_session_url
  #end
  
  #def test_user_should_not_update_tag
  #  sign_in users(:user1)
  #  put :update, :id => 'next-l', :tag => { }
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_update_tag
  #  sign_in users(:librarian1)
  #  put :update, :id => 'next-l', :tag => {:synonym => 'hoge'}
  #  assert_redirected_to tag_url(assigns(:tag).name)
  #end
  
  def test_guest_should_not_destroy_tag
    old_count = Tag.count
    delete :destroy, :id => 'next-l'
    assert_equal old_count, Tag.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_tag
    sign_in users(:user1)
    old_count = Tag.count
    delete :destroy, :id => 'next-l'
    assert_equal old_count, Tag.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_tag
    sign_in users(:librarian1)
    old_count = Tag.count
    delete :destroy, :id => 'next-l'
    assert_equal old_count-1, Tag.count
    
    assert_redirected_to tags_url
  end
end
