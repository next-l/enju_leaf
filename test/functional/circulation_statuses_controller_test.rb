require 'test_helper'

class CirculationStatusesControllerTest < ActionController::TestCase
  fixtures :circulation_statuses, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:circulation_statuses)
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
  
  def test_guest_should_not_create_circulation_status
    assert_no_difference('CirculationStatus.count') do
      post :create, :circulation_status => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_circulation_status
    sign_in users(:user1)
    assert_no_difference('CirculationStatus.count') do
      post :create, :circulation_status => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_circulation_status
    sign_in users(:librarian1)
    assert_no_difference('CirculationStatus.count') do
      post :create, :circulation_status => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_circulation_status_without_name
    sign_in users(:admin)
    assert_no_difference('CirculationStatus.count') do
      post :create, :circulation_status => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_circulation_status
    sign_in users(:admin)
    assert_difference('CirculationStatus.count') do
      post :create, :circulation_status => {:name => 'test'}
    end
    
    assert_redirected_to circulation_status_url(assigns(:circulation_status))
  end

  def test_guest_should_show_circulation_status
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_circulation_status
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_circulation_status
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_circulation_status
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
  
  def test_guest_should_not_update_circulation_status
    put :update, :id => 1, :circulation_status => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_circulation_status
    sign_in users(:user1)
    put :update, :id => 1, :circulation_status => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_circulation_status
    sign_in users(:librarian1)
    put :update, :id => 1, :circulation_status => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_circulation_status_without_name
    sign_in users(:admin)
    put :update, :id => 1, :circulation_status => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_circulation_status
    sign_in users(:admin)
    put :update, :id => 1, :circulation_status => { }
    assert_redirected_to circulation_status_url(assigns(:circulation_status))
  end
  
  def test_guest_should_not_destroy_circulation_status
    assert_no_difference('CirculationStatus.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_circulation_status
    sign_in users(:user1)
    assert_no_difference('CirculationStatus.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_circulation_status
    sign_in users(:librarian1)
    assert_no_difference('CirculationStatus.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_circulation_status
    sign_in users(:admin)
    assert_difference('CirculationStatus.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to circulation_statuses_url
  end
end
