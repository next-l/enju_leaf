require 'test_helper'

class OwnsControllerTest < ActionController::TestCase
    fixtures :owns, :users, :resources, :items, :patrons

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:owns)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:owns)
  end

  def test_user_should_get_index_with_patron_id
    sign_in users(:user1)
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:owns)
  end

  def test_user_should_get_index_with_item_id
    sign_in users(:user1)
    get :index, :item_id => 1
    assert_response :success
    assert assigns(:owns)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:owns)
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
  
  def test_librarian_should_get_new_with_username
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_own
    assert_no_difference('Own.count') do
      post :create, :own => {:patron_id => 1, :item_id => 1}
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_own
    sign_in users(:user1)
    assert_no_difference('Own.count') do
      post :create, :own => {:patron_id => 1, :item_id => 1}
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_own_without_patron_id
    sign_in users(:librarian1)
    assert_no_difference('Own.count') do
      post :create, :own => {:item_id => 1}
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_own_without_item_id
    sign_in users(:librarian1)
    assert_no_difference('Own.count') do
      post :create, :own => {:patron_id => 1}
    end
    
    assert_response :success
  end

  def test_librarian_should_create_own
    sign_in users(:librarian1)
    assert_difference('Own.count') do
      post :create, :own => {:patron_id => 1, :item_id => 3}
    end
    
    assert_redirected_to own_url(assigns(:own))
  end

  def test_guest_should_show_own
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_own
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_own
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
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_own
    put :update, :id => 1, :own => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_own
    sign_in users(:user1)
    put :update, :id => 1, :own => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_own_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => 1, :own => {:patron_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_own_without_item_id
    sign_in users(:librarian1)
    put :update, :id => 1, :own => {:item_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_own
    sign_in users(:librarian1)
    put :update, :id => 1, :own => { }
    assert_redirected_to own_url(assigns(:own))
  end
  
  def test_guest_should_not_destroy_own
    assert_no_difference('Own.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_destroy_own
    sign_in users(:user1)
    assert_no_difference('Own.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
  
  def test_librarian_should_destroy_own
    sign_in users(:librarian1)
    assert_difference('Own.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to owns_url
  end
end
