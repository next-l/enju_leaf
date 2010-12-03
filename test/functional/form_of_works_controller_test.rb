require 'test_helper'

class FormOfWorksControllerTest < ActionController::TestCase
    fixtures :form_of_works, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:form_of_works)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:form_of_works)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:form_of_works)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:form_of_works)
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
  
  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end
  
  def test_admin_should_not_get_new
    sign_in users(:admin)
    get :new
    assert_response :forbidden
  end
  
  def test_guest_should_not_create_form_of_work
    assert_no_difference('FormOfWork.count') do
      post :create, :form_of_work => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_form_of_work
    sign_in users(:user1)
    assert_no_difference('FormOfWork.count') do
      post :create, :form_of_work => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_form_of_work
    sign_in users(:librarian1)
    assert_no_difference('FormOfWork.count') do
      post :create, :form_of_work => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_form_of_work
    sign_in users(:admin)
    assert_no_difference('FormOfWork.count') do
      post :create, :form_of_work => {:name => 'test1'}
    end
    
    assert_response :forbidden
  end

  def test_guest_should_show_form_of_work
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_form_of_work
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_form_of_work
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_form_of_work
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_form_of_work
    put :update, :id => 1, :form_of_work => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_form_of_work
    sign_in users(:user1)
    put :update, :id => 1, :form_of_work => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_form_of_work
    sign_in users(:librarian1)
    put :update, :id => 1, :form_of_work => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_form_of_work_without_name
    sign_in users(:admin)
    put :update, :id => 1, :form_of_work => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_form_of_work
    sign_in users(:admin)
    put :update, :id => 1, :form_of_work => { }
    assert_redirected_to form_of_work_url(assigns(:form_of_work))
  end
  
  test "admin should update form_of_work with position" do
    sign_in users(:admin)
    put :update, :id => 1, :form_of_work => { }, :position => 2
    assert_redirected_to form_of_works_path
  end

  def test_guest_should_not_destroy_form_of_work
    assert_no_difference('FormOfWork.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_form_of_work
    sign_in users(:user1)
    assert_no_difference('FormOfWork.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_form_of_work
    sign_in users(:librarian1)
    assert_no_difference('FormOfWork.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_destroy_form_of_work
    sign_in users(:admin)
    assert_no_difference('FormOfWork.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
end
