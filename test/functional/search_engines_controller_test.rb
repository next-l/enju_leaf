require 'test_helper'

class SearchEnginesControllerTest < ActionController::TestCase
  fixtures :search_engines, :library_groups, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:search_engines)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:search_engines)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:search_engines)
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
  
  def test_guest_should_not_create_search_engine
    assert_no_difference('SearchEngine.count') do
      post :create, :search_engine => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_search_engine
    sign_in users(:user1)
    assert_no_difference('SearchEngine.count') do
      post :create, :search_engine => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_search_engine
    sign_in users(:librarian1)
    assert_no_difference('SearchEngine.count') do
      post :create, :search_engine => { }
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_search_engine_without_name
    sign_in users(:admin)
    assert_no_difference('SearchEngine.count') do
      post :create, :search_engine => { }
    end
    
    assert_response :success
  end

  def test_admin_should_create_search_engine
    sign_in users(:admin)
    assert_difference('SearchEngine.count') do
      post :create, :search_engine => {:name => 'test', :url => 'http://www.example.com/', :base_url => 'http://www.example.com/search', :http_method => 'get', :query_param => 'test'}
    end
    
    assert_redirected_to search_engine_url(assigns(:search_engine))
  end

  def test_guest_should_show_search_engine
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_search_engine
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :forbidden
  end

  def test_librarian_should_show_search_engine
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_search_engine
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
  
  def test_guest_should_not_update_search_engine
    put :update, :id => 1, :search_engine => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_search_engine
    sign_in users(:user1)
    put :update, :id => 1, :search_engine => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_search_engine
    sign_in users(:librarian1)
    put :update, :id => 1, :search_engine => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_search_engine_without_name
    sign_in users(:admin)
    put :update, :id => 1, :search_engine => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_search_engine
    sign_in users(:admin)
    put :update, :id => 1, :search_engine => {:name => 'test', :url => 'http://www.example.com/', :base_url => 'http://www.example.com/search', :http_method => 'get', :query_param => 'test'}
    assert_redirected_to search_engine_url(assigns(:search_engine))
  end
  
  def test_admin_should_update_search_engine_with_position
    sign_in users(:admin)
    put :update, :id => 1, :search_engine => { }, :position => 2
    assert_redirected_to search_engines_url
  end

  def test_guest_should_not_destroy_search_engine
    assert_no_difference('SearchEngine.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_search_engine
    sign_in users(:user1)
    assert_no_difference('SearchEngine.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_search_engine
    sign_in users(:librarian1)
    assert_no_difference('SearchEngine.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_search_engine
    sign_in users(:admin)
    assert_difference('SearchEngine.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to search_engines_url
  end
end
