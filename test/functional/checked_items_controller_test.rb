require 'test_helper'

class CheckedItemsControllerTest < ActionController::TestCase
  fixtures :checked_items, :baskets, :items, :manifestations,
    :realizes, :carrier_types,
    :item_has_use_restrictions, :use_restrictions,
    :checkout_types, :user_group_has_checkout_types,
    :checkouts, :reserves, :circulation_statuses, :carrier_type_has_checkout_types,
    :users, :roles, :patrons, :patron_types, :user_groups, :lending_policies

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index, :basket_id => 3, :item_id => 3
    assert_response :forbidden
  end

  def test_guest_should_not_create_checked_item
    assert_no_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00004'}, :basket_id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_checked_item_without_item_id
    sign_in users(:admin)
    assert_no_difference('CheckedItem.count') do
      post :create, :checked_item => { }, :basket_id => 1
    end
    
    assert_response :success
    #assert_redirected_to user_basket_checked_items_url(assigns(:basket).user.username, assigns(:basket))
  end

  def test_everyone_should_not_create_checked_item_without_basket_id
    sign_in users(:admin)
    assert_no_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00004'}
    end
    
    assert_response :forbidden
  end

  def test_user_should_not_create_checked_item
    sign_in users(:user1)
    assert_no_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00004'}, :basket_id => 3
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_create_checked_item_with_list
    sign_in users(:librarian1)
    assert_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00011'}, :basket_id => 3, :mode => 'list'
    end
    assert_not_nil assigns(:checked_item).due_date
    
    assert_redirected_to basket_checked_items_url(assigns(:checked_item).basket, :mode => 'list')
  end
  
  def test_system_should_show_message_when_item_includes_supplements
    sign_in users(:librarian1)
    assert_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00006'}, :basket_id => 3
    end
    assert_not_nil assigns(:checked_item).due_date
    
    assert_redirected_to basket_checked_items_url(assigns(:checked_item).basket)
    assert flash[:message].index(I18n.t('item.this_item_include_supplement'))
    #assert_nil assigns(:checked_item).errors
  end
  
  def test_librarian_should_not_create_checked_item_when_over_checkout_limit
    sign_in users(:librarian1)
    assert_no_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00011'}, :basket_id => 1
    end
    
    assert_response :success
    #assert_redirected_to user_basket_checked_items_path(assigns(:basket).user.username, assigns(:basket))
    assert assigns(:checked_item).errors["base"].include?(I18n.t('activerecord.errors.messages.checked_item.excessed_checkout_limit'))
  end

  def test_librarian_should_create_checked_item_when_ignore_restriction_is_enabled
    sign_in users(:librarian1)
    assert_difference('CheckedItem.count') do
      post :create, :checked_item => {:item_identifier => '00011', :ignore_restriction => "1"}, :basket_id => 2, :mode => 'list'
    end
    assert_not_nil assigns(:checked_item).due_date
    
    assert_redirected_to basket_checked_items_url(assigns(:checked_item).basket, :mode => 'list')
  end

  def test_guest_should_not_show_checked_item
    get :show, :id => 1, :basket_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_not_show_checked_item_without_basket_id
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_user_should_not_show_checked_item
    sign_in users(:user1)
    get :show, :id => 3, :basket_id => 3
    assert_response :forbidden
  end

  def test_librarian_should_show_checked_item
    sign_in users(:librarian1)
    get :show, :id => 1, :basket_id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1, :basket_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_edit_without_basket_id
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 3, :basket_id => 3
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :basket_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_checked_item
    put :update, :id => 1, :checked_item => { }, :basket_id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_update_checked_item_without_basket_id
    sign_in users(:admin)
    put :update, :id => 1, :checked_item => { }
    assert_response :forbidden
  end

  def test_user_should_not_update_checked_item
    sign_in users(:user1)
    put :update, :id => 1, :checked_item => { }, :basket_id => 3
    assert_response :forbidden
  end

  def test_librarian_should_not_update_checked_item_without_basket_id
    sign_in users(:librarian1)
    put :update, :id => 1, :checked_item => {}
    assert_response :forbidden
  end

  def test_librarian_should_update_checked_item
    sign_in users(:librarian1)
    put :update, :id => 4, :checked_item => { }, :basket_id => 8
    assert_redirected_to checked_item_url(assigns(:checked_item))
    #assert_nil assigns(:checked_item).errors
  end

  def test_guest_should_not_destroy_checked_item
    assert_no_difference('CheckedItem.count') do
      delete :destroy, :id => 1, :basket_id => 1
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_checked_item_without_basket_id
    sign_in users(:admin)
    assert_no_difference('CheckedItem.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
  
  def test_user_should_not_destroy_checked_item
    sign_in users(:user1)
    assert_no_difference('CheckedItem.count') do
      delete :destroy, :id => 3, :basket_id => 3
    end
    
    assert_response :forbidden
  end
  
  def test_librarian_should_destroy_checked_item
    sign_in users(:librarian1)
    assert_difference('CheckedItem.count', -1) do
      delete :destroy, :id => 1, :basket_id => 1
    end
    
    assert_redirected_to basket_checked_items_url(assigns(:checked_item).basket)
  end
end
