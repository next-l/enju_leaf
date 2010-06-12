require 'test_helper'

class LibraryGroupsControllerTest < ActionController::TestCase
    fixtures :library_groups, :users, :libraries

  def test_guest_should_not_get_index
    get :index
    assert_response :success
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
  end

  def test_librarian_should_not_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:library_groups)
  end

  def test_guest_should_not_get_new
    get :new
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
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_library_group
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_library_group
    sign_in users(:user1)
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_library_group
    sign_in users(:librarian1)
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_group_without_name
    sign_in users(:admin)
    old_count = LibraryGroup.count
    post :create, :library_group => { }
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_library_group
    sign_in users(:admin)
    old_count = LibraryGroup.count
    post :create, :library_group => {:name => 'test'}
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
    #assert_redirected_to library_group_url(assigns(:library_group))
  end

  def test_guest_should_show_library_group
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_library_group
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_library_group
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_library_group
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_library_group
    put :update, :id => 1, :library_group => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_library_group
    sign_in users(:user1)
    put :update, :id => 1, :library_group => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_library_group
    sign_in users(:librarian1)
    put :update, :id => 1, :library_group => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_library_group_without_name
    sign_in users(:admin)
    put :update, :id => 1, :library_group => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_library_group
    sign_in users(:admin)
    put :update, :id => 1, :library_group => { }
    assert_redirected_to library_group_url(assigns(:library_group))
  end
  
  def test_guest_should_not_destroy_library_group
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_library_group
    sign_in users(:user1)
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_library_group
    sign_in users(:librarian1)
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_destroy_library_group
    sign_in users(:admin)
    old_count = LibraryGroup.count
    delete :destroy, :id => 1
    assert_equal old_count, LibraryGroup.count
    
    assert_response :forbidden
    #assert_redirected_to library_groups_url
  end
end
