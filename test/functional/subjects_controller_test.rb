require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase
  fixtures :subjects, :users, :manifestations, :work_has_subjects

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:work)
    assert assigns(:subjects)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:subjects)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:subjects)
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
  
  def test_guest_should_not_create_subject
    assert_no_difference('Subject.count') do
      post :create, :subject => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subject
    sign_in users(:user1)
    assert_no_difference('Subject.count') do
      post :create, :subject => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subject
    sign_in users(:librarian1)
    assert_no_difference('Subject.count') do
      post :create, :subject => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_subject_without_term
    sign_in users(:admin)
    assert_no_difference('Subject.count') do
      post :create, :subject => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_subject
    sign_in users(:admin)
    assert_difference('Subject.count') do
      post :create, :subject => {:term => 'test', :subject_type_id => 1}
    end
    
    assert_redirected_to subject_url(assigns(:subject))
  end

  def test_guest_should_show_subject
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_guest_should_show_subject_with_work_id
    get :show, :id => subjects(:subject_00001).to_param, :work_id => 1
    assert_response :success
    assert assigns(:subject)
    assert assigns(:work)
  end

  def test_user_should_show_subject
    sign_in users(:user1)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_librarian_should_show_subject
    sign_in users(:librarian1)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_admin_should_show_subject
    sign_in users(:admin)
    get :show, :id => subjects(:subject_00001).to_param
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => subjects(:subject_00001).to_param
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param
    assert_response :success
  end
  
  def test_admin_should_get_edit_with_work
    sign_in users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :work_id => 1
    assert_response :success
  end
  
  def test_admin_should_not_get_edit_with_missing_work
    sign_in users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :work_id => 100
    assert_response :missing
  end
  
  def test_guest_should_not_update_subject
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subject
    sign_in users(:user1)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subject
    sign_in users(:librarian1)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_subject_without_term
    sign_in users(:admin)
    put :update, :id => subjects(:subject_00001).to_param, :subject => {:term => nil}
    assert_response :success
  end
  
  def test_admin_should_update_subject
    sign_in users(:admin)
    put :update, :id => subjects(:subject_00001).to_param, :subject => { }
    assert_redirected_to subject_url(assigns(:subject))
  end
  
  def test_guest_should_not_destroy_subject
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subject
    sign_in users(:user1)
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_subject
    sign_in users(:librarian1)
    assert_no_difference('Subject.count') do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_subject
    sign_in users(:admin)
    assert_difference('Subject.count', -1) do
      delete :destroy, :id => subjects(:subject_00001).to_param
    end
    
    assert_redirected_to subjects_url
  end
end
