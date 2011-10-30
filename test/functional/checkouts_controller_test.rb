require 'test_helper'

class CheckoutsControllerTest < ActionController::TestCase
  fixtures :checkouts, :users, :patrons, :roles, :user_groups, :reserves, :baskets, :library_groups, :checkout_types, :patron_types,
    :user_group_has_checkout_types, :carrier_type_has_checkout_types,
    :manifestations, :carrier_types,
    :items, :circulation_statuses

  def test_admin_should_get_other_index
    sign_in users(:admin)
    get :index, :user_id => users(:user1).username
    assert_response :success
  end

  def test_guest_should_not_show_checkout_without_username
    get :show, :id => 1, :user_id => users(:admin).username
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_missing_checkout
    sign_in users(:user1)
    get :show, :id => 100, :user_id => users(:user1).username
    assert_response :missing
  end

  def test_librarian_should_show_other_checkout
    sign_in users(:librarian1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_admin_should_show_other_checkout
    sign_in users(:admin)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
end
