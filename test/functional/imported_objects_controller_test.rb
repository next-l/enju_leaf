require 'test_helper'

class ImportedObjectsControllerTest < ActionController::TestCase
    fixtures :imported_objects, :users, :patrons, :events,
    :languages, :user_groups, :libraries, :library_groups, :patron_types,
    :event_import_files, :patron_import_files, :resource_import_files

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:imported_objects)
  end

  def test_everyone_should_not_get_new
    sign_in users(:admin)
    get :new
    assert_response :forbidden
  end

  def test_everyone_should_not_create_imported_object
    sign_in users(:admin)
    assert_no_difference('ImportedObject.count') do
      post :create, :imported_object => {:imported_file_id => 1, :importable_id => 2, :importable_type => 'Patron'}
    end

    assert_response :forbidden
    #assert_redirected_to imported_object_path(assigns(:imported_object))
  end

  def test_librarian_should_show_imported_object
    sign_in users(:librarian1)
    get :show, :id => imported_objects(:imported_object_00001).id
    assert_response :success
  end

  def test_everyone_should_not_get_edit
    sign_in users(:admin)
    get :edit, :id => imported_objects(:imported_object_00001).id
    assert_response :forbidden
  end

  def test_everyone_should_not_update_imported_object
    sign_in users(:admin)
    put :update, :id => imported_objects(:imported_object_00001).id, :imported_object => { }
    assert_response :forbidden
    #assert_redirected_to imported_object_path(assigns(:imported_object))
  end

  def test_everyone_should_not_destroy_imported_object
    sign_in users(:admin)
    assert_no_difference('ImportedObject.count', -1) do
      delete :destroy, :id => imported_objects(:imported_object_00001).id
    end

    assert_response :forbidden
    #assert_redirected_to imported_objects_path
  end
end
