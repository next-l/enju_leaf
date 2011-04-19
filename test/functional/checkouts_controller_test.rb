require 'test_helper'

class CheckoutsControllerTest < ActionController::TestCase
  fixtures :checkouts, :users, :patrons, :roles, :user_groups, :reserves, :baskets, :library_groups, :checkout_types, :patron_types,
    :user_group_has_checkout_types, :carrier_type_has_checkout_types,
    :manifestations, :carrier_types,
    :items, :circulation_statuses

  def test_guest_should_not_get_index
    get :index, :user_id => users(:admin).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  def test_guest_should_not_get_index_without_user_id
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_get_index_without_user_id
    sign_in users(:user1)
    get :index
    assert_response :redirect
    assert_redirected_to user_checkouts_url(users(:user1))
  end

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_user_should_get_my_index_feed
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username, :format => 'rss'
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_guest_should_get_ics
    # icsファイルは誰でもアクセスできるので、URLを他人に公開してはならない
    get :index, :icalendar_token => users(:user1).checkout_icalendar_token
    assert_response :success
    assert assigns(:checkouts)
  end

  def test_user_should_not_get_other_index
    sign_in users(:user1)
    get :index, :user_id => users(:admin).username
    assert_response :forbidden
  end

  def test_user_should_not_get_overdue_index
    sign_in users(:user1)
    get :index, :view => 'overdue'
    assert_response :redirect
    assert_redirected_to user_checkouts_url(users(:user1))
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
  end

  def test_librarian_should_get_index_csv
    sign_in users(:librarian1)
    get :index, :format => 'csv'
    assert_response :success
  end

  def test_librarian_should_get_index_rss
    sign_in users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
  end

  def test_librarian_should_get_other_index
    sign_in users(:librarian1)
    get :index, :user_id => users(:admin).username
    assert_response :success
  end

  def test_librarian_should_get_overdue_index
    sign_in users(:librarian1)
    get :index, :view => 'overdue'
    assert_response :success
  end

  def test_librarian_should_get_overdue_index_with_number_of_days_overdue
    sign_in users(:librarian1)
    get :index, :view => 'overdue', :days_overdue => 2
    assert_response :success
    assert assigns(:checkouts).size > 0
  end

  def test_librarian_should_get_overdue_index_with_invalid_number_of_days
    sign_in users(:librarian1)
    get :index, :view => 'overdue', :days_overdue => 'invalid days'
    assert_response :success
    assert assigns(:checkouts).size > 0
  end

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

  def test_user_should_show_my_checkout
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_not_show_other_checkout
    sign_in users(:user1)
    get :show, :id => 1, :user_id => users(:admin).username
    assert_response :forbidden
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

  def test_guest_should_not_get_edit
    get :edit, :id => 1, :user_id => users(:admin).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_edit_without_user_id
    sign_in users(:admin)
    get :edit, :id => 1
    #assert_response :forbidden
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    sign_in users(:user1)
    get :edit, :id => 1, :user_id => users(:admin).username
    assert_response :forbidden
  end
  
  def test_librarian_should_get_other_edit
    sign_in users(:librarian1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_admin_should_get_other_edit
    sign_in users(:admin)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_guest_should_not_update_checkout
    put :update, :id => 1, :user_id => users(:admin).username, :checkout => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_update_checkout_without_user_id
    sign_in users(:admin)
    put :update, :id => 1, :checkout => { }
    #assert_response :forbidden
    assert_response :missing
  end
  
  def test_everyone_should_not_update_missing_checkout
    sign_in users(:admin)
    put :update, :id => 100, :user_id => users(:admin).username, :checkout => { }
    assert_response :missing
  end
  
  def test_user_should_update_my_checkout
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user, assigns(:checkout))
  end
  
  def test_user_should_not_update_checkout_without_item_id
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :checkout => {:item_id => nil}
    assert_response :success
  end
  
  def test_user_should_not_update_other_checkout
    sign_in users(:user1)
    put :update, :id => 1, :user_id => users(:admin).username, :checkout => { }
    assert_response :forbidden
  end
  
  def test_user_should_not_update_already_renewed_checkout
    sign_in users(:user1)
    put :update, :id => 9, :user_id => users(:user1).username, :checkout => { }
    assert_equal I18n.t('checkout.excessed_renewal_limit'), flash[:notice]
    assert_response :redirect
    assert_redirected_to edit_user_checkout_url(assigns(:checkout).user, assigns(:checkout))
  end
  
  def test_librarian_should_update_checkout_item_is_reserved
    sign_in users(:librarian1)
    put :update, :id => 8, :user_id => users(:librarian1).username, :checkout => { }
    assert_equal I18n.t('checkout.this_item_is_reserved'), flash[:notice]
    assert_response :redirect
    assert_redirected_to edit_user_checkout_url(assigns(:checkout).user, assigns(:checkout))
  end
  
  def test_librarian_should_update_other_checkout
    sign_in users(:librarian1)
    put :update, :id => 1, :user_id => users(:admin).username, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user, assigns(:checkout))
  end
  
  def test_admin_should_update_other_checkout
    sign_in users(:admin)
    put :update, :id => 3, :user_id => users(:user1).username, :checkout => { }
    assert_redirected_to user_checkout_url(assigns(:checkout).user, assigns(:checkout))
  end
  
  def test_guest_should_not_destroy_checkout
    assert_no_difference('Checkout.count') do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to new_user_session_url 
  end

  def test_everyone_should_not_destroy_checkout_without_user_id
    sign_in users(:admin)
    assert_no_difference('Checkout.count') do
      delete :destroy, :id => 3
    end
    
    #assert_response :forbidden
    assert_response :missing
  end

  def test_everyone_should_not_destroy_missing_checkout
    sign_in users(:admin)
    assert_no_difference('Checkout.count') do
      delete :destroy, :id => 100, :user_id => users(:admin).username
    end
    
    assert_response :missing
  end

  def test_user_should_destroy_my_checkout
    sign_in users(:user1)
    assert_difference('Checkout.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to user_checkouts_url(users(:user1))
  end
  
  def test_librarian_should_destroy_other_checkout
    sign_in users(:librarian1)
    assert_difference('Checkout.count', -1) do
      delete :destroy, :id => 1, :user_id => users(:admin).username
    end
    
    #assert_response :forbidden
    assert_redirected_to user_checkouts_url(users(:admin))
  end

  def test_admin_should_destroy_other_checkout
    sign_in users(:admin)
    assert_difference('Checkout.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    #assert_response :forbidden
    assert_redirected_to user_checkouts_url(users(:user1))
  end

end
