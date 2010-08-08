require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  fixtures :orders, :purchase_requests, :order_lists, :patrons, :users

  def test_guest_should_not_get_index
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
    assert assigns(:orders)
  end

  def test_librarian_should_get_index_feed
    sign_in users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:orders)
  end

  def test_librarian_should_get_index_with_order_list_id
    sign_in users(:librarian1)
    get :index, :order_list_id => 1
    assert_response :success
    assert assigns(:orders)
  end

  def test_librarian_should_get_index_with_purchase_request_id
    sign_in users(:librarian1)
    get :index, :purchase_request_id => 1
    assert_response :success
    assert assigns(:orders)
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
  
  def test_librarian_should_not_get_new_without_purchase_request_id
    sign_in users(:librarian1)
    get :new
    assert_response :redirect
    assert_redirected_to purchase_requests_url
  end
  
  def test_librarian_should_get_new_with_purchase_request_id
    sign_in users(:librarian1)
    get :new, :purchase_request_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_order
    assert_no_difference('Order.count') do
      post :create, :order => { :order_list_id => 1, :purchase_request_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_order
    assert_no_difference('Order.count') do
      post :create, :order => { :order_list_id => 1, :purchase_request_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_order_without_order_list_id
    sign_in users(:librarian1)
    assert_no_difference('Order.count') do
      post :create, :order => { :purchase_request_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_order_without_purchase_request_id
    sign_in users(:librarian1)
    assert_no_difference('Order.count') do
      post :create, :order => { :order_list_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_order_already_created
    sign_in users(:librarian1)
    assert_no_difference('Order.count') do
      post :create, :order => { :order_list_id => 1, :purchase_request_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_order_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Order.count') do
      post :create, :order => { :order_list_id => 1, :purchase_request_id => 5 }
    end
    
    assert_redirected_to order_url(assigns(:order))
  end

  def test_guest_should_not_show_order
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_order
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_order
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
    get :edit, :id => 1, :order_list_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :order_list_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_order
    put :update, :id => 1, :order => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_order
    sign_in users(:user1)
    put :update, :id => 1, :order => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_order_without_order_list_id
    sign_in users(:librarian1)
    put :update, :id => 1, :order => {:order_list_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_order_without_purchase_request_id
    sign_in users(:librarian1)
    put :update, :id => 1, :order => {:purchase_request_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_order
    sign_in users(:librarian1)
    put :update, :id => 1, :order => { }
    assert_redirected_to order_url(assigns(:order))
  end
  
  def test_guest_should_not_destroy_order
    assert_no_difference('Order.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_order
    sign_in users(:user1)
    assert_no_difference('Order.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_order
    sign_in users(:librarian1)
    assert_difference('Order.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to orders_url
  end

  def test_librarian_should_destroy_order_with_order_list_id
    sign_in users(:librarian1)
    assert_difference('Order.count', -1) do
      delete :destroy, :id => 1, :order_list_id => 1
    end
    
    assert_redirected_to order_list_purchase_requests_url(assigns(:order_list))
  end

end
