require 'test_helper'

class EventCategoriesControllerTest < ActionController::TestCase
    fixtures :event_categories, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:event_categories)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:event_categories)
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
  
  def test_guest_should_not_create_event_category
    assert_no_difference('EventCategory.count') do
      post :create, :event_category => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_event_category
    sign_in users(:user1)
    assert_no_difference('EventCategory.count') do
      post :create, :event_category => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_event_category
    sign_in users(:librarian1)
    assert_no_difference('EventCategory.count') do
      post :create, :event_category => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_event_category_without_name
    sign_in users(:admin)
    assert_no_difference('EventCategory.count') do
      post :create, :event_category => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_event_category
    sign_in users(:admin)
    assert_difference('EventCategory.count') do
      post :create, :event_category => {:name => 'test'}
    end
    
    assert_redirected_to event_category_url(assigns(:event_category))
  end

  def test_guest_should_show_event_category
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_event_category
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_event_category
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_event_category
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
  
  def test_guest_should_not_update_event_category
    put :update, :id => 1, :event_category => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_event_category
    sign_in users(:user1)
    put :update, :id => 1, :event_category => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_event_category
    sign_in users(:librarian1)
    put :update, :id => 1, :event_category => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_event_category_without_name
    sign_in users(:admin)
    put :update, :id => 1, :event_category => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_event_category
    sign_in users(:admin)
    put :update, :id => 1, :event_category => { }
    assert_redirected_to event_category_url(assigns(:event_category))
  end
  
  def test_guest_should_not_destroy_event_category
    assert_no_difference('EventCategory.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_event_category
    sign_in users(:user1)
    assert_no_difference('EventCategory.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_event_category
    sign_in users(:librarian1)
    assert_no_difference('EventCategory.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_event_category
    sign_in users(:admin)
    assert_difference('EventCategory.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to event_categories_url
  end
end
