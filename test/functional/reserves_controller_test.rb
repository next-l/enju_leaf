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

  def test_user_should_get_my_index
    sign_in users(:user1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:reserves)
  end

  def test_user_should_not_get_other_index
    sign_in users(:user1)
    get :index, :user_id => users(:user2).username
    assert_response :forbidden
  end

  def test_librarian_should_get_index_feed_without_user_id
    sign_in users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:reserves)
  end

  def test_librarian_should_get_other_index
    sign_in users(:librarian1)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:reserves)
  end

  def test_librarian_should_get_other_index_feed
    sign_in users(:librarian1)
    get :index, :user_id => users(:user1).username, :format => 'rss'
    assert_response :success
    assert assigns(:reserves)
  end

  def test_admin_should_get_other_index
    sign_in users(:admin)
    get :index, :user_id => users(:user1).username
    assert_response :success
    assert assigns(:reserves)
  end

  def test_guest_should_not_get_new
    get :new, :user_id => users(:user1).username, :manifestation_id => 3
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_get_my_new_when_user_number_is_set
    sign_in users(:user1)
    get :new, :user_id => users(:user1).username, :manifestation_id => 3
    assert_response :success
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
  
  def test_librarian_should_get_new_without_user_id
    sign_in users(:librarian1)
    get :new, :manifestation_id => 3
    assert_response :success
  end
  
  def test_librarian_should_get_other_new
    sign_in users(:librarian1)
    get :new, :user_id => users(:user1).username, :manifestation_id => 3
    assert_response :success
  end
  
  def test_admin_should_get_other_new
    sign_in users(:admin)
    get :new, :user_id => users(:user1).username, :manifestation_id => 3
    assert_response :success
  end
  
  def test_guest_should_not_create_reserve
    assert_no_difference('Reserve.count') do
      post :create, :reserve => { }
    end
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_reserve_without_manifestation_id
    sign_in users(:admin)
    assert_no_difference('Reserve.count') do
      post :create, :user_id => users(:admin).username, :reserve => {:user_number => users(:admin).user_number}
    end
    
    assert_response :success
  end

  def test_everyone_should_not_create_reserve_with_past_date
    sign_in users(:admin)
    assert_no_difference('Reserve.count') do
      post :create, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5, :expired_at => '1901-01-01'}
    end
    
    assert_response :success
  end

  def test_user_should_create_my_reserve
    sign_in users(:user1)
    assert_difference('Reserve.count') do
      post :create, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    end
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
    assert assigns(:reserve).expired_at > Time.zone.now
  end

  def test_user_should_not_create_other_reserve
    sign_in users(:user1)
    assert_no_difference('Reserve.count') do
      post :create, :user_id => users(:user2).username, :reserve => {:user_number => users(:user2).user_number, :manifestation_id => 6}
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_create_reserve_without_user_id
    sign_in users(:librarian1)
    assert_difference('Reserve.count') do
      post :create, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    end
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_librarian_should_create_other_reserve
    sign_in users(:librarian1)
    assert_difference('Reserve.count') do
      post :create, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    end
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_admin_should_create_other_reserve
    sign_in users(:admin)
    assert_difference('Reserve.count') do
      post :create, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number, :manifestation_id => 5}
    end
    assert assigns(:reserve).expired_at
    
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_everyone_should_not_create_reserve_over_reserve_limit
    sign_in users(:librarian1)
    assert_no_difference('Reserve.count') do
      post :create, :user_id => users(:admin).username, :reserve => {:user_number => users(:admin).user_number, :manifestation_id => 5}
    end
    assert assigns(:reserve).errors[:base].include? I18n.t('reserve.excessed_reservation_limit')
    
    #assert_redirected_to resource_url(assigns(:manifestation))
  end

  def test_guest_should_not_show_reserve
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_show_missing_reserve
    sign_in users(:admin)
    get :show, :id => 100, :user_id => users(:user1).username
    assert_response :missing
  end

  def test_user_should_show_reserve_without_user_id
    sign_in users(:user1)
    get :show, :id => 3
    assert_response :success
  end

  def test_user_should_show_my_reserve
    sign_in users(:user1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_user_should_not_show_other_reserve
    sign_in users(:user2)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :forbidden
  end

  def test_librarian_should_show_reserve_without_user_id
    sign_in users(:librarian1)
    get :show, :id => 3
    assert_response :success
  end

  def test_librarian_should_show_other_reserve
    sign_in users(:librarian1)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_admin_should_show_other_reserve
    sign_in users(:admin)
    get :show, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 3
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_missing_edit
    sign_in users(:admin)
    get :edit, :id => 100
    assert_response :missing
  end
  
  def test_user_should_get_my_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :success
  end
  
  def test_user_should_not_get_other_edit
    sign_in users(:user1)
    get :edit, :id => 5, :user_id => users(:user2).username
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit_without_user_id
    sign_in users(:librarian1)
    get :edit, :id => 3
    assert_response :success
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
  
  def test_guest_should_not_update_reserve
    put :update, :id => 1, :reserve => { }
    assert_response :redirect
  end
  
  def test_everyone_should_not_update_reserve_without_manifestation_id
    sign_in users(:admin)
    put :update, :id => 1, :user_id => users(:admin).username, :reserve => {:user_number => users(:admin).user_number, :manifestation_id => nil}
    assert_response :success
  end
  
  def test_user_should_not_update_missing_reserve
    sign_in users(:user1)
    put :update, :id => 100, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number}
    assert_response :missing
  end
  
  def test_user_should_update_my_reserve
    sign_in users(:user1)
    put :update, :id => 3, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number}
    assert_equal I18n.t('controller.successfully_updated', :model => I18n.t('activerecord.models.reserve')), flash[:notice]
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_user_should_cancel_my_reserve
    sign_in users(:user1)
    old_message_requests_count = MessageRequest.count
    put :update, :id => 3, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_equal I18n.t('reserve.reservation_was_canceled'), flash[:notice]
    assert_equal 'canceled', assigns(:reserve).state
    assert_equal old_message_requests_count + 2, MessageRequest.count
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_user_should_not_update_other_reserve
    sign_in users(:user1)
    put :update, :id => 5, :user_id => users(:user2).username, :reserve => {:user_number => users(:user2).user_number}
    assert_response :forbidden
  end
  
  def test_user_should_not_cancel_other_reserve
    sign_in users(:user1)
    put :update, :id => 5, :user_id => users(:user2).username, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_response :forbidden
  end

  def test_librarian_should_update_without_user_id
    sign_in users(:librarian1)
    put :update, :id => 3, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_librarian_should_update_other_reserve
    sign_in users(:librarian1)
    put :update, :id => 3, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_librarian_should_cancel_other_reserve
    sign_in users(:librarian1)
    old_message_requests_count = MessageRequest.count
    put :update, :id => 3, :user_id => users(:user1).username, :reserve => {:user_number => users(:user1).user_number}, :mode => 'cancel'
    assert_equal I18n.t('reserve.reservation_was_canceled'), flash[:notice]
    assert_equal 'canceled', assigns(:reserve).state
    assert_equal old_message_requests_count + 2, MessageRequest.count
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_admin_should_update_other_reserve_without_user_id
    sign_in users(:admin)
    put :update, :id => 3, :reserve => {:user_number => users(:user1).user_number}
    assert_redirected_to user_reserve_url(users(:user1).username, assigns(:reserve))
  end

  def test_guest_should_not_destroy_reserve
    assert_no_difference('Reserve.count') do
      delete :destroy, :id => 1
    end
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_reserve_without_user_id
    sign_in users(:user1)
    assert_no_difference('Reserve.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_missing_reserve
    sign_in users(:admin)
    assert_no_difference('Reserve.count') do
      delete :destroy, :id => 100, :user_id => users(:user1).username
    end
    
    assert_response :missing
  end

  def test_user_should_destroy_my_reserve
    sign_in users(:user1)
    assert_difference('Reserve.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to user_reserves_url(users(:user1).username)
  end

  def test_user_should_not_destroy_other_reserve
    sign_in users(:user1)
    assert_no_difference('Reserve.count') do
      delete :destroy, :id => 5, :user_id => users(:user2).username
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_other_reserve
    sign_in users(:librarian1)
    assert_difference('Reserve.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to user_reserves_url(users(:user1).username)
  end

  def test_user_should_destroy_other_reserve
    sign_in users(:admin)
    assert_difference('Reserve.count', -1) do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_redirected_to user_reserves_url(users(:user1).username)
  end

end
