require 'test_helper'

class SubscribesControllerTest < ActionController::TestCase
    fixtures :subscribes, :subscriptions, :users, :patrons, :patron_types,
      :languages, :roles, :manifestations, :carrier_types, :form_of_works

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
    assert assigns(:subscribes)
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
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_subscribe
    assert_no_difference('Subscribe.count') do
      post :create, :subscribe => { :work_id => 1, :subscription_id => 1 }
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_subscribe
    sign_in users(:user1)
    assert_no_difference('Subscribe.count') do
      post :create, :subscribe => { :work_id => 1, :subscription_id => 1 }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_create_without_work_id
    sign_in users(:librarian1)
    assert_no_difference('Subscribe.count') do
      post :create, :subscribe => { :subscription_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_without_subscription_id
    sign_in users(:librarian1)
    assert_no_difference('Subscribe.count') do
      post :create, :subscribe => { :work_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_already_created
    sign_in users(:librarian1)
    assert_no_difference('Subscribe.count') do
      post :create, :subscribe => { :start_at => Time.zone.now.to_s, :end_at => 1.day.from_now.to_s, :work_id => 1, :subscription_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_subscribe_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Subscribe.count') do
      post :create, :subscribe => { :start_at => Time.zone.now.to_s, :end_at => 1.day.from_now.to_s, :work_id => 3, :subscription_id => 1 }
    end
    
    assert_redirected_to subscribe_url(assigns(:subscribe))
  end

  def test_guest_should_not_show_subscribe
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_subscribe
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_subscribe
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
    get :edit, :id => 1, :work_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :work_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_subscribe
    put :update, :id => 1, :subscribe => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_subscribe
    sign_in users(:user1)
    put :update, :id => 1, :subscribe => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_create_without_work_id
    sign_in users(:librarian1)
    put :update, :id => 1, :subscribe => {:work_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_create_without_subscription_id
    sign_in users(:librarian1)
    put :update, :id => 1, :subscribe => {:subscription_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_subscribe
    sign_in users(:librarian1)
    put :update, :id => 1, :subscribe => { }
    assert_redirected_to subscribe_url(assigns(:subscribe))
  end
  
  def test_guest_should_not_destroy_subscribe
    assert_no_difference('Subscribe.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_subscribe
    sign_in users(:user1)
    assert_no_difference('Subscribe.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_subscribe
    sign_in users(:librarian1)
    assert_difference('Subscribe.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to subscribes_url
  end
end
