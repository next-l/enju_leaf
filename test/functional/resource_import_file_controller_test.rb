# -*- encoding: utf-8 -*-
require 'test_helper'

class ResourceImportFilesControllerTest < ActionController::TestCase
  fixtures :resource_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories, :circulation_statuses,
    :series_statements

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

  def test_librarian_should_create_resource_import_file_only_isbn
    sign_in users(:librarian1)
    old_manifestations_count = Manifestation.count
    old_patrons_count = Patron.count
    assert_difference('ResourceImportFile.count') do
      post :create, :resource_import_file => {:resource_import => fixture_file_upload("../../examples/isbn_sample.txt", 'text/plain') }
    end
    # 後でバッチで処理する
    #assert_equal old_manifestations_count + 1, Manifestation.count
    #assert_equal old_patrons_count + 5, Patron.count

    assert_redirected_to resource_import_file_path(assigns(:resource_import_file))
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
end
