require 'test_helper'

class PictureFilesControllerTest < ActionController::TestCase
    fixtures :picture_files, :resources, :carrier_types, :events, :languages, :users, :user_groups, :patrons, :patron_types, :event_categories, :libraries, :reserves, :library_groups, :countries, :shelves

  def test_guest_should_get_index
    get :index
    #assert_response :redirect
    #assert_redirected_to new_user_session_url
    assert_response :success
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    #assert_response :forbidden
    assert_response :success
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:picture_files)
  end

  def test_librarian_should_get_index_with_manifestation_id
    sign_in users(:librarian1)
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert_not_nil assigns(:picture_files)
  end

  def test_librarian_should_get_index_with_event_id
    sign_in users(:librarian1)
    get :index, :event_id => 1
    assert_response :success
    assert assigns(:event)
    assert_not_nil assigns(:picture_files)
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

  def test_librarian_should_not_get_new_without_manifestation_id
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  def test_librarian_should_get_new_upload
    sign_in users(:librarian1)
    get :new, :upload => true, :manifestation_id => 1
    assert_response :success
  end

  def test_librarian_should_get_new_with_manifestation_id
    sign_in users(:librarian1)
    get :new, :manifestation_id => 1
    assert_response :success
  end

  def test_librarian_should_get_new_with_event_id
    sign_in users(:librarian1)
    get :new, :event_id => 1
    assert_response :success
  end

  def test_guest_should_not_create_picture_file
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Resource', :picture_attachable_id => 1, :picture => 'test upload'}
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_picture_file
    sign_in users(:user1)
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Resource', :picture_attachable_id => 1}
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_picture_file_without_picture_attachable_type
    sign_in users(:librarian1)
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_id => 1, :picture => fixture_file_upload("spinner.gif", "image/gif")}
    end

    assert_response :success
    #assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_not_create_picture_file_without_picture_attachable_id
    sign_in users(:librarian1)
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Resource', :picture => fixture_file_upload("spinner.gif", "image/gif")}
    end

    assert_response :success
    #assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_librarian_should_not_create_picture_file_without_attachment
    sign_in users(:librarian1)
    assert_no_difference('PictureFile.count') do
      post :create, :picture_file => {:picture_attachable_type => 'Resource', :picture_attachable_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_picture_file
    sign_in users(:librarian1)
    assert_difference('PictureFile.count', 1) do
      post :create, :picture_file => {:picture_attachable_type => 'Shelf', :picture_attachable_id => 1, :picture => fixture_file_upload("spinner.gif", "image/gif")}
    end

    assert assigns(:picture_file).picture_attachable
    assert_redirected_to picture_file_url(assigns(:picture_file))
    #assert assigns(:picture_file).file_hash
  end

  def test_guest_should_show_picture_file
    get :show, :id => picture_files(:picture_file_00001)
    #assert_response :redirect
    assert_response :success
  end

  def test_user_should_show_picture_file
    sign_in users(:user1)
    get :show, :id => picture_files(:picture_file_00001)
    #assert_response :forbidden
    assert_response :success
  end

  def test_librarian_should_show_picture_file
    sign_in users(:librarian1)
    get :show, :id => picture_files(:picture_file_00001)
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => picture_files(:picture_file_00001)
    assert_response :success
  end

  def test_guest_should_not_update_picture_file
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_picture_file
    sign_in users(:user1)
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_picture_file_without_picture_attachable_id
    sign_in users(:librarian1)
    put :update, :id => picture_files(:picture_file_00001), :picture_file => {:picture_attachable_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_picture_file_without_picture_attachable_type
    sign_in users(:librarian1)
    put :update, :id => picture_files(:picture_file_00001), :picture_file => {:picture_attachable_type => nil}
    assert_response :success
  end

  def test_librarian_should_update_picture_file
    sign_in users(:librarian1)
    put :update, :id => picture_files(:picture_file_00001), :picture_file => { }
    assert_response :redirect
    assert_redirected_to picture_file_url(assigns(:picture_file))
  end

  def test_guest_should_not_destroy_picture_file
    assert_no_difference('PictureFile.count') do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_picture_file
    sign_in users(:user1)
    assert_no_difference('PictureFile.count') do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_picture_file
    sign_in users(:librarian1)
    assert_difference('PictureFile.count', -1) do
      delete :destroy, :id => picture_files(:picture_file_00001)
    end

    assert_response :redirect
    assert_redirected_to picture_files_url
  end
end
