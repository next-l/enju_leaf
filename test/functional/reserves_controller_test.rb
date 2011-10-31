require 'test_helper'

class ReservesControllerTest < ActionController::TestCase
  fixtures :reserves, :items, :manifestations, :carrier_types,
    :users, :user_groups, :roles, :checkout_types,
    :user_group_has_checkout_types, :carrier_type_has_checkout_types,
    :request_status_types, :message_templates, :message_requests

  def test_guest_should_not_get_index
    get :index, :user_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_admin_should_get_other_index
    sign_in users(:admin)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:reserves)
  end

  def test_user_should_not_get_my_new_when_user_number_is_not_set
    sign_in users(:user2)
    get :new, :user_id => users(:user2).username, :manifestation_id => 3
    assert_response :forbidden
  end
  
  def test_user_should_not_get_other_new
    sign_in users(:user1)
    get :new, :user_id => users(:user2).username, :manifestation_id => 5
    assert_response :forbidden
  end
end
