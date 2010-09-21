require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  fixtures :countries, :users, :roles

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:countries)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:countries)
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
    assert_response :forbidden
  end
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_country
    assert_no_difference('Country.count') do
      post :create, :country => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_country
    sign_in users(:user1)
    assert_no_difference('Country.count') do
      post :create, :country => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_country
    sign_in users(:librarian1)
    assert_no_difference('Country.count') do
      post :create, :country => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_country_without_name
    sign_in users(:admin)
    assert_no_difference('Country.count') do
      post :create, :country => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_country
    sign_in users(:admin)
    assert_difference('Country.count') do
      post :create, :country => {:name => 'test', :alpha_2 => '000', :alpha_3 => '000', :numeric_3 => '000'}
    end
    
    assert_redirected_to country_url(assigns(:country))
  end

  def test_guest_should_show_country
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_country
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_country
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_country
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_country
    put :update, :id => 1, :country => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_country
    sign_in users(:user1)
    put :update, :id => 1, :country => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_country
    sign_in users(:librarian1)
    put :update, :id => 1, :country => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_country_without_name
    sign_in users(:admin)
    put :update, :id => 1, :country => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_country
    sign_in users(:admin)
    put :update, :id => 1, :country => {:name => 'test', :alpha_2 => '000', :alpha_3 => '000', :numeric_3 => '000'}
    assert_redirected_to country_url(assigns(:country))
  end
  
  test "admin should update country with position" do
    sign_in users(:admin)
    put :update, :id => countries(:country_00001), :country => { }, :position => 2
    assert_redirected_to countries_path
  end

  def test_guest_should_not_destroy_country
    assert_no_difference('Country.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_country
    sign_in users(:user1)
    assert_no_difference('Country.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_country
    sign_in users(:librarian1)
    assert_no_difference('Country.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_country
    sign_in users(:admin)
    assert_difference('Country.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to countries_url
  end
end
