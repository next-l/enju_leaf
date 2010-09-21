require 'test_helper'

class ResourceImportFilesControllerTest < ActionController::TestCase
  fixtures :resource_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories, :circulation_statuses,
    :imported_objects, :series_statements

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:resource_import_files)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:resource_import_files)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_import_files)
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

  def test_guest_should_not_create_resource_import_file
    assert_no_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_resource_import_file
    sign_in users(:user1)
    assert_no_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_resource_import_file
    sign_in users(:librarian1)
    old_manifestations_count = Resource.count
    old_items_count = Item.count
    old_patrons_count = Patron.count
    assert_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => {:resource_import => fixture_file_upload("resource_import_file_sample1.tsv", 'text/plain') }
    end
    # 後でバッチで処理する
    assigns(:resource_import_file).import_start
    assert_equal old_manifestations_count + 5, Resource.count
    assert_equal old_items_count + 5, Item.count
    assert_equal old_patrons_count + 5, Patron.count

    assert_equal 'librarian1', assigns(:resource_import_file).user.username
    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
    assert_equal 2, Item.find_by_item_identifier('10101').manifestation.creators.size
    assert_nil Item.find_by_item_identifier('10104')
    item = Item.find_by_item_identifier('11111')
    assert_equal Shelf.find_by_name('first_shelf'), item.shelf
    assert_equal 1000, item.manifestation.price
    assert_equal 0, item.price
    assert_equal 2, item.manifestation.publishers.size
    #assert assigns(:resource_import_file).file_hash
  end

  def test_librarian_should_create_resource_import_file_only_isbn
    sign_in users(:librarian1)
    old_manifestations_count = Resource.count
    old_patrons_count = Patron.count
    assert_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => {:resource_import => fixture_file_upload("isbn_sample.txt", 'text/plain') }
    end
    # 後でバッチで処理する
    #assert_equal old_manifestations_count + 1, Resource.count
    #assert_equal old_patrons_count + 5, Patron.count

    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
  end

  def test_guest_should_not_show_resource_import_file
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_resource_import_file
    sign_in users(:user1)
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_resource_import_file
    sign_in users(:librarian1)
    get :show, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => resource_import_files(:resource_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_resource_import_file
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_resource_import_file
    sign_in users(:user1)
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_resource_import_file
    sign_in users(:librarian1)
    put :update, :id => resource_import_files(:resource_import_file_00003).id, :resource_import_file => { }
    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
  end

  def test_guest_should_not_destroy_resource_import_file
    assert_no_difference('ResourceImportFile.count') do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_resource_import_file
    sign_in users(:user1)
    assert_no_difference('ResourceImportFile.count') do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_resource_import_file
    sign_in users(:librarian1)
    assert_difference('ResourceImportFile.count', -1) do
      delete :destroy, :id => resource_import_files(:resource_import_file_00003).id
    end

    assert_redirected_to resource_import_files_path
  end
end
