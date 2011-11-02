require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  fixtures :orders, :purchase_requests, :order_lists, :patrons, :users

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :order_list_id => 1
    assert_response :success
  end
  
  def test_librarian_should_not_update_order_without_purchase_request_id
    sign_in users(:librarian1)
    put :update, :id => 1, :order => {:purchase_request_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_destroy_order_with_order_list_id
    sign_in users(:librarian1)
    assert_difference('Order.count', -1) do
      delete :destroy, :id => 1, :order_list_id => 1
    end
    
    assert_redirected_to order_list_purchase_requests_url(assigns(:order_list))
  end
end
