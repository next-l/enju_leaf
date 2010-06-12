require 'test_helper'

class InventoryFilesControllerTest < ActionController::TestCase
    fixtures :inventory_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:inventory_files)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:inventory_files)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:inventory_files)
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

  def test_guest_should_not_create_inventory_file
    assert_no_difference('InventoryFile.count') do
      post :create, :inventory_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_inventory_file
    sign_in users(:user1)
    assert_no_difference('InventoryFile.count') do
      post :create, :inventory_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_inventory_file
    sign_in users(:librarian1)
    old_count = Inventory.count
    assert_difference('InventoryFile.count') do
      post :create, :inventory_file => {:inventory => fixture_file_upload("inventory_file_sample.txt", 'text/csv') }
    end
    assert_equal old_count + 3, Inventory.count
    assert_equal 'librarian1', assigns(:inventory_file).user.username

    assert_redirected_to inventory_file_url(assigns(:inventory_file))
  end

  def test_guest_should_not_show_inventory_file
    get :show, :id => inventory_files(:inventory_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_inventory_file
    sign_in users(:user1)
    get :show, :id => inventory_files(:inventory_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_inventory_file
    sign_in users(:librarian1)
    get :show, :id => inventory_files(:inventory_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => inventory_files(:inventory_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => inventory_files(:inventory_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => inventory_files(:inventory_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_inventory_file
    put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_inventory_file
    sign_in users(:user1)
    put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_inventory_file
    sign_in users(:librarian1)
    put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
    assert_redirected_to inventory_file_url(assigns(:inventory_file))
  end

  def test_guest_should_not_destroy_inventory_file
    assert_no_difference('InventoryFile.count') do
      delete :destroy, :id => inventory_files(:inventory_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_inventory_file
    sign_in users(:user1)
    assert_no_difference('InventoryFile.count') do
      delete :destroy, :id => inventory_files(:inventory_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_inventory_file
    sign_in users(:librarian1)
    assert_difference('InventoryFile.count', -1) do
      delete :destroy, :id => inventory_files(:inventory_file_00003).id
    end

    assert_redirected_to inventory_files_path
  end
end
