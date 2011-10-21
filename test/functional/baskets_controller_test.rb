require 'test_helper'

class BasketsControllerTest < ActionController::TestCase
  fixtures :baskets, :checked_items, :checkouts, :reserves,
    :items, :circulation_statuses, :manifestations, :carrier_types,
    :languages, :users, :roles

  def test_user_should_not_create_basket
    sign_in users(:user1)
    assert_no_difference('Basket.count') do
      post :create, :basket => {:user_number => users(:user1).user_number }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_basket_without_user_number
    sign_in users(:librarian1)
    assert_no_difference('Basket.count') do
      post :create, :basket => { }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_basket
    sign_in users(:librarian1)
    assert_difference('Basket.count') do
      post :create, :basket => {:user_number => users(:user1).user_number }
    end
    
    assert_redirected_to user_basket_checked_items_url(users(:user1).username, assigns(:basket))
  end

  def test_librarian_should_not_create_basket_when_user_is_suspended
    sign_in users(:librarian1)
    assert_no_difference('Basket.count') do
      post :create, :basket => {:user_number => users(:user4).user_number }
    end
    
    assert assigns(:basket).errors["base"].include?(I18n.t('basket.this_account_is_suspended'))
    assert_response :success
  end

  def test_librarian_should_not_create_basket_when_user_is_not_found
    sign_in users(:librarian1)
    assert_no_difference('Basket.count') do
      post :create, :basket => {:user_number => 'not found' }
    end
    
    assert assigns(:basket).errors["base"].include?(I18n.t('user.not_found'))
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1, :user_id => users(:admin).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 3, :user_id => users(:user1).username
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :user_id => users(:admin).username
    assert_response :success
  end
  
  def test_guest_should_not_destroy_basket
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).username
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_basket
    sign_in users(:user1)
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).username
    assert_response :forbidden
  end

  def test_librarian_should_destroy_basket_without_user_id
    sign_in users(:librarian1)
    delete :destroy, :id => 1, :basket => {:user_id => nil}, :user_id => users(:user1).username
    assert_response :redirect
    assert_redirected_to user_checkouts_url(assigns(:basket).user.username)
  end

  def test_librarian_should_destroy_basket
    sign_in users(:librarian1)
    delete :destroy, :id => 1, :basket => { }, :user_id => users(:user1).username
    assert_redirected_to user_checkouts_url(assigns(:basket).user.username)
  end

  def test_guest_should_not_destroy_basket
    assert_no_difference('Basket.count') do
      delete :destroy, :id => 1, :user_id => users(:admin).username
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_basket
    sign_in users(:user1)
    assert_no_difference('Basket.count') do
      delete :destroy, :id => 3, :user_id => users(:user1).username
    end
    
    assert_response :forbidden
  end
  
  def test_librarian_should_update_basket_when_not_checked_out
    sign_in users(:librarian1)
    put :update, :id => 8, :user_id => users(:user1).username
    assert_equal 'On Loan', assigns(:basket).checkouts.first.item.circulation_status.name
    
    assert_redirected_to user_checkouts_url(assigns(:basket).user)
  end

  #def test_system_should_show_notice_when_patron_reserved_checkout_items
  #  sign_in users(:librarian1)
  #  put :update, :id => 8, :user_id => users(:user1).username
  #  assert_equal 'This item is reserved by this patron. Reservation completed.', flash[:reserved]
  #  assert_nil flash[:notice]
    
  #  assert_redirected_to user_basket_checked_items_url(assigns(:user).username, assigns(:basket))
  #end

  #def test_system_should_show_notice_when_other_patron_reserved
  #  sign_in users(:librarian1)
  #  assert_no_difference('Basket.count') do
  #   put :update, :id => 2, :user_id => users(:librarian1).username
  #  end
  #  assert_equal 'Reserved item included!', flash[:reserved]
  #  
  #  assert_redirected_to user_basket_checked_items_url(assigns(:user).username, assigns(:basket))
  #end

end
