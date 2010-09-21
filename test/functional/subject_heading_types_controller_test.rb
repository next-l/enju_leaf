require 'test_helper'

class SubjectHeadingTypesControllerTest < ActionController::TestCase
  fixtures :subject_heading_types, :users, :subjects, :subject_types,
    :subject_heading_type_has_subjects, :resources, :carrier_types

  def test_guest_should_not_get_index
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:subject_heading_types)
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
  
  def test_guest_should_not_create_subject_heading_type
    assert_no_difference('SubjectHeadingType.count') do
      post :create, :subject_heading_type => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subject_heading_type
    sign_in users(:user1)
    assert_no_difference('SubjectHeadingType.count') do
      post :create, :subject_heading_type => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subject_heading_type
    sign_in users(:librarian1)
    assert_no_difference('SubjectHeadingType.count') do
      post :create, :subject_heading_type => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_subject_heading_type_without_name
    sign_in users(:admin)
    assert_no_difference('SubjectHeadingType.count') do
      post :create, :subject_heading_type => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_subject_heading_type
    sign_in users(:admin)
    assert_difference('SubjectHeadingType.count') do
      post :create, :subject_heading_type => {:name => 'test'}
    end
    
    assert_redirected_to subject_heading_type_url(assigns(:subject_heading_type))
  end

  def test_guest_should_show_subject_heading_type
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_user_should_show_subject_heading_type
    sign_in users(:user1)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_librarian_should_show_subject_heading_type
    sign_in users(:librarian1)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_admin_should_show_subject_heading_type
    sign_in users(:admin)
    get :show, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => subject_heading_types(:subject_heading_type_00001).id
    assert_response :success
  end
  
  def test_guest_should_not_update_subject_heading_type
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subject_heading_type
    sign_in users(:user1)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subject_heading_type
    sign_in users(:librarian1)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_subject_heading_type_without_name
    sign_in users(:admin)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_subject_heading_type
    sign_in users(:admin)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }
    assert_redirected_to subject_heading_type_url(assigns(:subject_heading_type))
  end
  
  test "admin should update subject_heading_type with position" do
    sign_in users(:admin)
    put :update, :id => subject_heading_types(:subject_heading_type_00001).id, :subject_heading_type => { }, :position => 2
    assert_redirected_to subject_heading_types_path
  end

  def test_guest_should_not_destroy_subject_heading_type
    assert_no_difference('SubjectHeadingType.count') do
      delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subject_heading_type
    sign_in users(:user1)
    assert_no_difference('SubjectHeadingType.count') do
      delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_subject_heading_type
    sign_in users(:librarian1)
    assert_no_difference('SubjectHeadingType.count') do
      delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_subject_heading_type
    sign_in users(:admin)
    assert_difference('SubjectHeadingType.count', -1) do
      delete :destroy, :id => subject_heading_types(:subject_heading_type_00001).id
    end
    
    assert_redirected_to subject_heading_types_url
  end
end
