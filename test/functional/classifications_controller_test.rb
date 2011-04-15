require 'test_helper'

class ClassificationsControllerTest < ActionController::TestCase
  fixtures :classifications, :classification_types, :users

  def test_guest_should_get_index_with_query
    get :index, :query => '500'
    assert_response :success
    assert assigns(:classifications)
  end

  def test_admin_should_create_classification
    sign_in users(:admin)
    assert_difference('Classification.count') do
      post :create, :classification => {:category => '000.0', :classification_type_id => '1'}
    end
    
    assert_redirected_to classification_url(assigns(:classification))
  end

  def test_admin_should_not_create_classification_already_created
    sign_in users(:admin)
    assert_no_difference('Classification.count') do
      post :create, :classification => {:category => '000', :classification_type_id => '1'}
    end
    
    assert_response :success
  end
end
