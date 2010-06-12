require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  fixtures :roles, :users

  def test_guest_should_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:roles)
  end

  #def test_guest_should_not_get_new
  #  get :new
  #  assert_response :redirect
  #  assert_redirected_to new_user_session_url
  #end
  
  #def test_user_should_not_get_new
  #  sign_in users(:user1)
  #  get :new
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_not_get_new
  #  sign_in users(:librarian1)
  #  get :new
  #  assert_response :forbidden
  #end
  
  #def test_admin_should_get_new
  #  sign_in users(:admin)
  #  get :new
  #  assert_response :success
  #  assert assigns(:role)
  #end
  
  #def test_guest_should_not_create_role
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :redirect
  #  assert_redirected_to new_user_session_url
  #end

  #def test_user_should_not_create_role
  #  sign_in users(:user1)
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end

  #def test_librarian_should_not_create_role
  #  sign_in users(:librarian1)
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end

  #def test_admin_should_create_role_without_name
  #  sign_in users(:admin)
  #  old_count = Role.count
  #  post :create, :role => { }
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :success
  #end

  #def test_admin_should_create_role
  #  sign_in users(:admin)
  #  old_count = Role.count
  #  post :create, :role => {:name => 'test'}
  #  assert_equal old_count+1, Role.count
  #  
  #  assert_redirected_to role_url(assigns(:role))
  #end

  def test_guest_should_not_show_role
    get :show, :id => 1
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_role
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_role
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
    assert assigns(:role)
  end

  def test_admin_should_show_role
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
    assert assigns(:role)
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
  
  def test_guest_should_not_update_role
    put :update, :id => 1, :role => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_role
    sign_in users(:user1)
    put :update, :id => 1, :role => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_role
    sign_in users(:librarian1)
    put :update, :id => 1, :role => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_role_without_name
    sign_in users(:admin)
    put :update, :id => 1, :role => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_role
    sign_in users(:admin)
    put :update, :id => 1, :role => { }
    assert_redirected_to role_url(assigns(:role))
  end
  
  #def test_guest_should_not_destroy_role
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :redirect
  #  assert_redirected_to new_user_session_url
  #end

  #def test_user_should_not_destroy_role
  #  sign_in users(:user1)
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_not_destroy_role
  #  sign_in users(:librarian1)
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count, Role.count
  #  
  #  assert_response :forbidden
  #end
  
  #def test_admin_should_destroy_role
  #  sign_in users(:admin)
  #  old_count = Role.count
  #  delete :destroy, :id => 1
  #  assert_equal old_count-1, Role.count
  #  
  #  assert_redirected_to roles_url
  #end
end
