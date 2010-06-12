require 'test_helper'

class ClassificationsControllerTest < ActionController::TestCase
  fixtures :classifications, :classification_types, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:classifications)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:classifications)
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
  
  def test_guest_should_not_create_classification
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_classification
    sign_in users(:user1)
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_classification
    sign_in users(:librarian1)
    old_count = Classification.count
    post :create, :classification => { }
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_admin_should_create_classification
    sign_in users(:admin)
    old_count = Classification.count
    post :create, :classification => {:category => '000.0', :classification_type_id => '1'}
    assert_equal old_count+1, Classification.count
    
    assert_redirected_to classification_url(assigns(:classification))
  end

  def test_admin_should_not_create_classification_already_created
    sign_in users(:admin)
    old_count = Classification.count
    post :create, :classification => {:category => '000', :classification_type_id => '1'}
    assert_equal old_count, Classification.count
    
    assert_response :success
  end

  def test_guest_should_show_classification
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_classification
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_classification
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_classification
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
  
  def test_guest_should_not_update_classification
    put :update, :id => 1, :classification => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_classification
    sign_in users(:user1)
    put :update, :id => 1, :classification => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_classification
    sign_in users(:librarian1)
    put :update, :id => 1, :classification => { }
    assert_response :forbidden
  end
  
  def test_admin_should_update_classification
    sign_in users(:admin)
    put :update, :id => 1, :classification => { }
    assert_redirected_to classification_url(assigns(:classification))
  end
  
  def test_guest_should_not_destroy_classification
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_classification
    sign_in users(:user1)
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_classification
    sign_in users(:librarian1)
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count, Classification.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_classification
    sign_in users(:admin)
    old_count = Classification.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Classification.count
    
    assert_redirected_to classifications_url
  end
end
