require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  fixtures :subscriptions, :users, :patrons, :patron_types, :languages, :roles

  def test_librarian_should_create_subscription
    sign_in users(:librarian1)
    assert_difference('Subscription.count') do
      post :create, :subscription => { :order_list_id => 1, :title => 'test' }
    end
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end

  def test_admin_should_create_subscription
    sign_in users(:admin)
    assert_difference('Subscription.count') do
      post :create, :subscription => { :order_list_id => 1, :title => 'test' }
    end
    
    assert_redirected_to subscription_url(assigns(:subscription))
  end
end
