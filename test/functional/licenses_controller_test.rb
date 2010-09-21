require 'test_helper'

class LicensesControllerTest < ActionController::TestCase
    fixtures :licenses, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:licenses)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:licenses)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:licenses)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:licenses)
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
  
  def test_guest_should_not_create_license
    assert_no_difference('License.count') do
      post :create, :license => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_license
    sign_in users(:user1)
    assert_no_difference('License.count') do
      post :create, :license => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_license
    sign_in users(:librarian1)
    assert_no_difference('License.count') do
      post :create, :license => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_license_without_name
    sign_in users(:admin)
    assert_no_difference('License.count') do
      post :create, :license => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_license
    sign_in users(:admin)
    assert_difference('License.count') do
      post :create, :license => {:name => 'test'}
    end
    
    assert_redirected_to license_url(assigns(:license))
  end

  def test_guest_should_show_license
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_license
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_license
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_license
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
  
  def test_guest_should_not_update_license
    put :update, :id => 1, :license => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_license
    sign_in users(:user1)
    put :update, :id => 1, :license => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_license
    sign_in users(:librarian1)
    put :update, :id => 1, :license => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_license_without_name
    sign_in users(:admin)
    put :update, :id => 1, :license => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_license
    sign_in users(:admin)
    put :update, :id => 1, :license => { }
    assert_redirected_to license_url(assigns(:license))
  end
  
  def test_admin_should_update_license_with_position
    sign_in users(:admin)
    put :update, :id => 1, :license => { }, :position => 2
    assert_redirected_to licenses_url
  end
  
  def test_guest_should_not_destroy_license
    assert_no_difference('License.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_license
    sign_in users(:user1)
    assert_no_difference('License.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_license
    sign_in users(:librarian1)
    assert_no_difference('License.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_license
    sign_in users(:admin)
    assert_difference('License.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to licenses_url
  end
end
