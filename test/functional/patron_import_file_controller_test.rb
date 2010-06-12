require 'test_helper'

class PatronImportFilesControllerTest < ActionController::TestCase
    fixtures :patron_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories,
    :imported_objects

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:patron_import_files)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:patron_import_files)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_import_files)
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

  def test_guest_should_not_create_patron_import_file
    assert_no_difference('PatronImportFile.count') do
      post :create, :patron_import_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_patron_import_file
    sign_in users(:user1)
    assert_no_difference('PatronImportFile.count') do
      post :create, :patron_import_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_patron_import_file
    sign_in users(:librarian1)
    old_patrons_count = Patron.count
    assert_difference('PatronImportFile.count') do
      post :create, :patron_import_file => {:patron_import => fixture_file_upload("patron_import_file_sample1.tsv", 'text/csv') }
    end
    assert_difference('Patron.count', 2) do
      assigns(:patron_import_file).import
    end
    assert_equal '田辺浩介', Patron.find(:first, :order => 'id DESC').full_name

    assert_equal 'librarian1', assigns(:patron_import_file).user.username
    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
    #assert assigns(:patron_import_file).file_hash
  end

  def test_librarian_should_import_user
    sign_in users(:librarian1)
    old_patrons_count = Patron.count
    assert_difference('PatronImportFile.count') do
      post :create, :patron_import_file => {:patron_import => fixture_file_upload("patron_import_file_sample2.tsv", 'text/csv') }
    end
    assert_difference('User.count', 1) do
      assigns(:patron_import_file).import
    end
    #assert_equal old_patrons_count + 1, Patron.count
    #assert_equal '日本語の名前', Patron.find(:first, :order => 'id DESC').full_name

    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end

  def test_guest_should_not_show_patron_import_file
    get :show, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_patron_import_file
    sign_in users(:user1)
    get :show, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_patron_import_file
    sign_in users(:librarian1)
    get :show, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => patron_import_files(:patron_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_patron_import_file
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_patron_import_file
    sign_in users(:user1)
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_patron_import_file
    sign_in users(:librarian1)
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end

  def test_guest_should_not_destroy_patron_import_file
    assert_no_difference('PatronImportFile.count') do
      delete :destroy, :id => patron_import_files(:patron_import_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_patron_import_file
    sign_in users(:user1)
    assert_no_difference('PatronImportFile.count') do
      delete :destroy, :id => patron_import_files(:patron_import_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_patron_import_file
    sign_in users(:librarian1)
    assert_difference('PatronImportFile.count', -1) do
      delete :destroy, :id => patron_import_files(:patron_import_file_00003).id
    end

    assert_redirected_to patron_import_files_path
  end
end
