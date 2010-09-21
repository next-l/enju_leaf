require 'test_helper'

class SeriesStatementsControllerTest < ActionController::TestCase
    fixtures :series_statements, :resources

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:series_statements)
  end

  def test_guest_should_get_index_with_query
    get :index, :query => 'title1'
    assert_response :success
    assert assigns(:series_statements)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:series_statements)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:series_statements)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:series_statements)
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
  
  def test_guest_should_not_create_series_statement
    assert_no_difference('SeriesStatement.count') do
      post :create, :series_statement => { }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_series_statement
    sign_in users(:user1)
    assert_no_difference('SeriesStatement.count') do
      post :create, :series_statement => { }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_series_statement_without_original_title
    sign_in users(:librarian1)
    assert_no_difference('SeriesStatement.count') do
      post :create, :series_statement => { }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_series_statement
    sign_in users(:librarian1)
    assert_difference('SeriesStatement.count') do
      post :create, :series_statement => {:original_title => 'test'}
    end
    
    assert_redirected_to series_statement_url(assigns(:series_statement))
  end

  def test_guest_should_show_series_statement
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_series_statement
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_series_statement
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_series_statement
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
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_series_statement
    put :update, :id => 1, :series_statement => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_series_statement
    sign_in users(:user1)
    put :update, :id => 1, :series_statement => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_series_statement_without_original_title
    sign_in users(:admin)
    put :update, :id => 1, :series_statement => {:original_title => ""}
    assert_response :success
  end
  
  def test_librarian_should_update_series_statement
    sign_in users(:librarian1)
    put :update, :id => 1, :series_statement => { }
    assert_redirected_to series_statement_url(assigns(:series_statement))
  end
  
  def test_librarian_should_update_series_statement_with_position
    sign_in users(:librarian1)
    put :update, :id => 1, :series_statement => { }, :position => 2
    assert_redirected_to series_statements_url
  end
  
  def test_guest_should_not_destroy_series_statement
    assert_no_difference('SeriesStatement.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_series_statement
    sign_in users(:user1)
    assert_no_difference('SeriesStatement.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_series_statement
    sign_in users(:librarian1)
    assert_difference('SeriesStatement.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to series_statements_url
  end
end
