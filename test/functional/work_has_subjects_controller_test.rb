require 'test_helper'

class WorkHasSubjectsControllerTest < ActionController::TestCase
  fixtures :work_has_subjects, :manifestations, :subject_heading_types, :users, :subjects, :subject_types, :roles

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:work_has_subjects)
  end

  def test_guest_should_get_index_with_subject_id
    get :index, :subject_id => 1
    assert_response :success
    assert assigns(:work_has_subjects)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:work_has_subjects)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:work_has_subjects)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:work_has_subjects)
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
  
  def test_guest_should_not_create_work_has_subject
    assert_no_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => { :subject_id => 1, :work_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_work_has_subject
    assert_no_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => { :subject_id => 1, :work_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_work_has_subject_without_subject_id
    sign_in users(:librarian1)
    assert_no_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => { :work_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_work_has_subject_without_work_id
    sign_in users(:librarian1)
    assert_no_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => { :subject_id => 1 }
    end

    assert_response :success
  end

  def test_librarian_should_not_create_work_has_subject_already_created
    sign_in users(:librarian1)
    assert_no_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => {:subject_id => 1, :work_id => 1}
      #post :create, :work_has_subject => { :subject_id => 1, :work_id => 1, :subject_type => 'Place' }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_work_has_subject_not_created_yet
    sign_in users(:librarian1)
    assert_difference('WorkHasSubject.count') do
      post :create, :work_has_subject => {:subject_id => 2, :work_id => 2}
      #post :create, :work_has_subject => { :subject_id => 1, :work_id => 1, :subject_type => 'Place' }
    end
    
    assert_redirected_to work_has_subject_url(assigns(:work_has_subject))
  end

  def test_guest_should_show_work_has_subject
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_work_has_subject
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_work_has_subject
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
    get :edit, :id => 1, :subject_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :subject_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_work_has_subject
    put :update, :id => 1, :work_has_subject => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_work_has_subject
    sign_in users(:user1)
    put :update, :id => 1, :work_has_subject => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_work_has_subject_without_subject_id
    sign_in users(:librarian1)
    put :update, :id => 1, :work_has_subject => {:subject_id => nil}
    assert_response :success
  end
  
  #def test_librarian_should_not_update_work_has_subject_without_work_id
  #  sign_in users(:librarian1)
  #  put :update, :id => 1, :work_has_subject => {:work_id => nil}
  #  assert_response :success
  #end
  
  def test_librarian_should_update_work_has_subject
    sign_in users(:librarian1)
    put :update, :id => 1, :work_has_subject => { }
    assert_redirected_to work_has_subject_url(assigns(:work_has_subject))
  end
  
  #def test_librarian_should_update_work_has_subject_with_position
  #  sign_in users(:librarian1)
  #  put :update, :id => 1, :work_has_subject => { }, :work_id => 1, :position => 1
  #  assert_redirected_to work_work_has_subjects_url(assigns(:work))
  #end
  
  def test_guest_should_not_destroy_work_has_subject
    assert_no_difference('WorkHasSubject.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_work_has_subject
    sign_in users(:user1)
    assert_no_difference('WorkHasSubject.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_work_has_subject
    sign_in users(:librarian1)
    assert_difference('WorkHasSubject.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to work_has_subjects_url
  end

  def test_librarian_should_destroy_work_has_subject_with_subject_id
    sign_in users(:librarian1)
    assert_difference('WorkHasSubject.count', -1) do
      delete :destroy, :id => 1, :subject_id => 1
    end
    
    assert_redirected_to subject_work_has_subjects_url(assigns(:subject))
  end

  def test_librarian_should_destroy_work_has_subject_with_work_id
    sign_in users(:librarian1)
    assert_difference('WorkHasSubject.count', -1) do
      delete :destroy, :id => 1, :work_id => 1
    end
    
    assert_redirected_to work_work_has_subjects_url(assigns(:manifestation))
  end
end
