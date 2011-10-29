require 'test_helper'

class PurchaseRequestsControllerTest < ActionController::TestCase
    fixtures :purchase_requests, :users, :order_lists, :orders

  def test_user_should_get_my_new
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username
    assert_response :success
  end

  def test_librarian_should_get_new_without_user_id
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  def test_guest_should_not_show_purchase_request
    get :show, :id => purchase_requests(:purchase_request_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_show_purchase_request_without_user_id
    sign_in users(:librarian1)
    get :show, :id => purchase_requests(:purchase_request_00002).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => purchase_requests(:purchase_request_00003).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_get_my_edit
    sign_in users(:user1)
    get :edit, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_not_get_other_edit
    sign_in users(:user1)
    get :edit, :id => purchase_requests(:purchase_request_00002).id, :user_id => users(:librarian1).username
    assert_response :forbidden
  end

  def test_librarian_should_get_edit_without_user_id
    sign_in users(:librarian1)
    get :edit, :id => purchase_requests(:purchase_request_00002).id
    assert_response :success
  end

  def test_user_should_destroy_my_purchase_request
    sign_in users(:user1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).username
    end

    assert_redirected_to purchase_requests_url
  end

  def test_user_should_not_destroy_other_purchase_request
    sign_in users(:user1)
    assert_no_difference('PurchaseRequest.count') do
      delete :destroy, :id => purchase_requests(:purchase_request_00002).id, :user_id => users(:librarian1).username
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_other_purchase_request
    sign_in users(:librarian1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id, :user_id => users(:user1).username
    end

    assert_redirected_to purchase_requests_url
  end

  def test_librarian_should_destroy_purchase_request_without_user_id
    sign_in users(:librarian1)
    assert_difference('PurchaseRequest.count', -1) do
      delete :destroy, :id => purchase_requests(:purchase_request_00003).id
    end

    assert_redirected_to purchase_requests_url
  end
end
