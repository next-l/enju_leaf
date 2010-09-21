require 'test_helper'

class CheckinsControllerTest < ActionController::TestCase
    fixtures :checkins, :checkouts, :users, :patrons, :roles, :user_groups, :reserves, :baskets, :library_groups, :checkout_types, :patron_types,
    :user_group_has_checkout_types, :carrier_type_has_checkout_types,
    :resources, :carrier_types,
    :items, :circulation_statuses,
    :shelves, :request_status_types,
    :content_types, :languages, :message_templates

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
    assert_response :redirect
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_librarian_should_get_index_with_basket_id
    sign_in users(:librarian1)
    get :index, :basket_id => 1
    assert_response :success
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
  
  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :redirect
    assert_redirected_to checkins_url
  end
  
  def test_guest_should_not_create_checkin
    assert_no_difference('Checkin.count') do
      post :create, :checkin => {:item_id => 3}, :basket => 9
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_checkin_without_item_id
    sign_in users(:admin)
    assert_no_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => nil}, :basket_id => 9
    end
    
    assert_response :redirect
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
    #assert_response :success
  end

  def test_user_should_not_create_checkin
    sign_in users(:user1)
    assert_no_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => '00003'}, :basket_id => 9
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_create_checkin
    sign_in users(:librarian1)
    assert_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => '00003'}, :basket_id => 9
    end
    
    assert_equal 'Available On Shelf', assigns(:checkin).item.circulation_status.name
    assert_not_nil assigns(:checkin).checkout
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_system_should_show_message_when_item_includes_supplements
    sign_in users(:librarian1)
    assert_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => '00004'}, :basket_id => 9
    end
    
    assert_equal 'Available On Shelf', assigns(:checkin).item.circulation_status.name
    assert flash[:message].index(I18n.t('item.this_item_include_supplement'))
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_system_should_show_notice_when_other_library_item
    sign_in users(:librarian2)
    assert_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => '00009'}, :basket_id => 9
    end
    assert flash[:message].index(I18n.t('checkin.other_library_item'))
    
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_system_should_show_notice_when_reserved
    sign_in users(:librarian1)
    assert_difference('Checkin.count') do
      post :create, :checkin => {:item_identifier => '00008'}, :basket_id => 9
    end
    assert flash[:message].index(I18n.t('item.this_item_is_reserved'))
    assert_equal 'retained', assigns(:checkin).item.next_reservation.state
    
    assert_redirected_to user_basket_checkins_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_guest_should_not_show_checkin
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_show_missing_checkin
    sign_in users(:admin)
    get :show, :id => 100
    assert_response :missing
  end

  def test_user_should_not_show_checkin
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_checkin
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_missing_edit
    sign_in users(:admin)
    get :edit, :id => 100
    assert_response :missing
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_checkin
    put :update, :id => 1, :checkin => { :item_identifier => 1 }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_update_missing_checkin
    sign_in users(:admin)
    put :update, :id => 100, :checkin => { }
    assert_response :missing
  end

  def test_everyone_should_not_update_checkin_without_item_identifier
    sign_in users(:admin)
    put :update, :id => 1, :checkin => {:item_identifier => nil}
    assert_response :success
  end

  def test_user_should_not_update_checkin
    sign_in users(:user1)
    put :update, :id => 1, :checkin => { :item_identifier => '00001' }
    assert_response :forbidden
  end

  def test_librarian_should_update_checkin
    sign_in users(:librarian1)
    put :update, :id => 1, :checkin => { :item_identifier => '00001' }
    assert_redirected_to checkin_url(assigns(:checkin))
  end

  def test_guest_should_not_destroy_checkin
    assert_no_difference('Checkin.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_missing_checkin
    sign_in users(:admin)
    assert_no_difference('Checkin.count') do
      delete :destroy, :id => 100
    end
    
    assert_response :missing
  end
  
  def test_user_should_not_destroy_checkin
    sign_in users(:user1)
    assert_no_difference('Checkin.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
  
  def test_librarian_should_destroy_checkin
    sign_in users(:librarian1)
    assert_difference('Checkin.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to checkins_url
  end
end
