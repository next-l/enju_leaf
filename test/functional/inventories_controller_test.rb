require 'test_helper'

class InventoriesControllerTest < ActionController::TestCase
    fixtures :inventory_files, :inventories, :users, :patrons, :patron_types, :items

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:inventories)
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
    assert_response :success
  end
  
  def test_guest_should_not_create_inventory
    assert_no_difference('Inventory.count') do
      post :create, :inventory => { :item_id => 1, :inventory_file_id => 1 }
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_inventory
    sign_in users(:user1)
    assert_no_difference('Inventory.count') do
      post :create, :inventory => { :item_id => 1, :inventory_file_id => 1 }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_create_without_item_id
    sign_in users(:librarian1)
    assert_no_difference('Inventory.count') do
      post :create, :inventory => { :inventory_file_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_without_inventory_file_id
    sign_in users(:librarian1)
    assert_no_difference('Inventory.count') do
      post :create, :inventory => { :item_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_already_created
    sign_in users(:librarian1)
    assert_no_difference('Inventory.count') do
      post :create, :inventory => { :item_id => 1, :inventory_file_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_inventory_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Inventory.count') do
      post :create, :inventory => { :item_id => 3, :inventory_file_id => 1 }
    end
    
    assert_redirected_to inventory_url(assigns(:inventory))
  end

  def test_guest_should_not_show_inventory
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_inventory
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_inventory
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1, :item_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :item_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_inventory
    put :update, :id => 1, :inventory => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_inventory
    sign_in users(:user1)
    put :update, :id => 1, :inventory => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_create_without_item_id
    sign_in users(:librarian1)
    put :update, :id => 1, :inventory => {:item_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_create_without_inventory_file_id
    sign_in users(:librarian1)
    put :update, :id => 1, :inventory => {:inventory_file_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_inventory
    sign_in users(:librarian1)
    put :update, :id => 1, :inventory => { }
    assert_redirected_to inventory_url(assigns(:inventory))
  end
  
  def test_guest_should_not_destroy_inventory
    assert_no_difference('Inventory.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_inventory
    sign_in users(:user1)
    assert_no_difference('Inventory.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_inventory
    sign_in users(:librarian1)
    assert_difference('Inventory.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to inventories_url
  end
end
