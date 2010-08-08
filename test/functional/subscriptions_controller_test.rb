require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  fixtures :subscriptions, :users, :patrons, :patron_types, :languages, :roles

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
    assert assigns(:subscriptions)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:subscriptions)
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
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_subscription
    assert_no_difference('Subscription.count') do
      post :create, :subscription => { :title => 'test' }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subscription
    sign_in users(:user1)
    assert_no_difference('Subscription.count') do
      post :create, :subscription => { :title => 'test' }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_subscription_without_title
    sign_in users(:librarian1)
    assert_no_difference('Subscription.count') do
      post :create, :subscription => { }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_subscription
    sign_in users(:librarian1)
    assert_difference('Subscription.count') do
      post :create, :subscription => { :order_list_id => 1, :title => 'test' }
    end
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end

  def test_admin_should_create_subscription
    sign_in users(:admin)
    assert_difference('Subscription.count') do
      post :create, :subscription => { :order_list_id => 1, :title => 'test' }
    end
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end

  def test_guest_should_not_show_subscription
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_subscription
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_subscription
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_subscription
    sign_in users(:admin)
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
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_subscription
    put :update, :id => 1, :subscription => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subscription
    sign_in users(:user1)
    put :update, :id => 1, :subscription => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_subscription_without_title
    sign_in users(:librarian1)
    put :update, :id => 1, :subscription => {:title => ""}
    assert_response :success
  end
  
  def test_librarian_should_update_subscription
    sign_in users(:librarian1)
    put :update, :id => 1, :subscription => { }
    assert_redirected_to subscription_url(assigns(:subscription))
  end
  
  def test_admin_should_update_subscription
    sign_in users(:admin)
    put :update, :id => 1, :subscription => { }
    assert_redirected_to subscription_url(assigns(:subscription))
  end
  
  def test_guest_should_not_destroy_subscription
    assert_no_difference('Subscription.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subscription
    sign_in users(:user1)
    assert_no_difference('Subscription.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_subscription
    sign_in users(:librarian1)
    assert_difference('Subscription.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to subscriptions_url
  end

  def test_admin_should_destroy_subscription
    sign_in users(:admin)
    assert_difference('Subscription.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to subscriptions_url
  end
end
