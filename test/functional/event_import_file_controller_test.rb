require 'test_helper'

class EventImportFilesControllerTest < ActionController::TestCase
    fixtures :event_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:event_import_files), []
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:event_import_files), []
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:event_import_files)
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

  def test_guest_should_not_create_event_import_file
    assert_no_difference('EventImportFile.count') do
      post :create, :event_import_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_event_import_file
    sign_in users(:user1)
    assert_no_difference('EventImportFile.count') do
      post :create, :event_import_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_event_import_file
    old_event_count = Event.count
    old_import_results_count = EventImportResult.count
    sign_in users(:librarian1)
    assert_difference('EventImportFile.count') do
      post :create, :event_import_file => {:event_import => fixture_file_upload("event_import_file_sample1.tsv", 'text/csv') }
    end

    assigns(:event_import_file).import_start
    assert_equal old_event_count + 2, Event.count
    assert_equal old_import_results_count + 3, EventImportResult.count
    assert_equal 'librarian1', assigns(:event_import_file).user.username
    assert_redirected_to event_import_file_url(assigns(:event_import_file))
    #assert assigns(:event_import_file).file_hash
  end

  def test_guest_should_not_show_event_import_file
    get :show, :id => event_import_files(:event_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_event_import_file
    sign_in users(:user1)
    get :show, :id => event_import_files(:event_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_show_event_import_file
    sign_in users(:librarian1)
    get :show, :id => event_import_files(:event_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => event_import_files(:event_import_file_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => event_import_files(:event_import_file_00003).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => event_import_files(:event_import_file_00003).id
    assert_response :success
  end

  def test_guest_should_not_update_event_import_file
    put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_event_import_file
    sign_in users(:user1)
    put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_event_import_file
    sign_in users(:librarian1)
    put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
    assert_redirected_to event_import_file_url(assigns(:event_import_file))
  end

  def test_guest_should_not_destroy_event_import_file
    assert_no_difference('EventImportFile.count') do
      delete :destroy, :id => event_import_files(:event_import_file_00003).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_event_import_file
    sign_in users(:user1)
    assert_no_difference('EventImportFile.count') do
      delete :destroy, :id => event_import_files(:event_import_file_00003).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_event_import_file
    sign_in users(:librarian1)
    assert_difference('EventImportFile.count', -1) do
      delete :destroy, :id => event_import_files(:event_import_file_00003).id
    end

    assert_redirected_to event_import_files_path
  end
end
