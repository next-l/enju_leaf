require 'test_helper'

class ShelvesControllerTest < ActionController::TestCase
  fixtures :shelves, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_guest_should_get_index_with_library_id
    get :index, :library_id => 'kamata'
    assert_response :success
    assert assigns(:shelves)
  end

  def test_guest_should_get_index_select
    get :index, :select => true
    assert_response :success
    assert assigns(:shelves)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:shelves)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:shelves)
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
  
  def test_guest_should_not_create_shelf
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_shelf
    sign_in users(:user1)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_shelf
    sign_in users(:librarian1)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_shelf_without_name
    sign_in users(:admin)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => nil }, :library_id => 'kamata'
    end
    
    assert_response :success
  end

  def test_admin_should_create_shelf
    sign_in users(:admin)
    assert_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }
    end
    assert_equal 'web', assigns(:shelf).library.name
    
    assert_redirected_to shelf_url(assigns(:shelf))
  end

  def test_admin_should_create_shelf_with_library
    sign_in users(:admin)
    assert_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    assert_equal 'kamata', assigns(:shelf).library.name
    
    assert_redirected_to shelf_url(assigns(:shelf))
  end

  def test_guest_should_show_shelf
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_shelf
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_shelf
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_shelf
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
  
  def test_guest_should_not_update_shelf
    put :update, :id => 1, :shelf => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_shelf
    sign_in users(:user1)
    put :update, :id => 1, :shelf => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_shelf
    sign_in users(:librarian1)
    put :update, :id => 1, :shelf => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_shelf_without_name
    sign_in users(:admin)
    put :update, :id => 1, :shelf => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_shelf
    sign_in users(:admin)
    put :update, :id => 1, :shelf => { }
    assert_redirected_to library_shelf_url(assigns(:shelf).library.name, assigns(:shelf))
  end
  
  def test_guest_should_not_destroy_shelf
    assert_no_difference('Shelf.count') do
      delete :destroy, :id => 2
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_shelf
    sign_in users(:user1)
    assert_no_difference('Shelf.count') do
      delete :destroy, :id => 2
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_shelf
    sign_in users(:librarian1)
    assert_no_difference('Shelf.count') do
      delete :destroy, :id => 2
    end
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_shelf_id_1
    sign_in users(:admin)
    assert_no_difference('Shelf.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_shelf
    sign_in users(:admin)
    assert_difference('Shelf.count', -1) do
      delete :destroy, :id => 2
    end
    
    assert_redirected_to library_shelves_url(assigns(:shelf).library.name)
  end
end
