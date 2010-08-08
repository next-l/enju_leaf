require 'test_helper'

class ExtentsControllerTest < ActionController::TestCase
    fixtures :extents, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:extents)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:extents)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:extents)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:extents)
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
  
  def test_guest_should_not_create_extent
    assert_no_difference('Extent.count') do
      post :create, :extent => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_extent
    sign_in users(:user1)
    assert_no_difference('Extent.count') do
      post :create, :extent => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_extent
    sign_in users(:librarian1)
    assert_no_difference('Extent.count') do
      post :create, :extent => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_extent_without_name
    sign_in users(:admin)
    assert_no_difference('Extent.count') do
      post :create, :extent => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_extent
    sign_in users(:admin)
    assert_difference('Extent.count') do
      post :create, :extent => {:name => 'test'}
    end
    
    assert_redirected_to extent_url(assigns(:extent))
  end

  def test_guest_should_show_extent
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_extent
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_extent
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_extent
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
  
  def test_guest_should_not_update_extent
    put :update, :id => 1, :extent => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_extent
    sign_in users(:user1)
    put :update, :id => 1, :extent => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_extent
    sign_in users(:librarian1)
    put :update, :id => 1, :extent => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_extent_without_name
    sign_in users(:admin)
    put :update, :id => 1, :extent => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_extent
    sign_in users(:admin)
    put :update, :id => 1, :extent => { }
    assert_redirected_to extent_url(assigns(:extent))
  end
  
  def test_guest_should_not_destroy_extent
    assert_no_difference('Extent.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_extent
    sign_in users(:user1)
    assert_no_difference('Extent.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_extent
    sign_in users(:librarian1)
    assert_no_difference('Extent.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_extent
    sign_in users(:admin)
    assert_difference('Extent.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to extents_url
  end
end
