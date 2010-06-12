require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase
    fixtures :languages, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:languages)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:languages)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:languages)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:languages)
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
  
  def test_guest_should_not_create_language
    old_count = Language.count
    post :create, :language => { }
    assert_equal old_count, Language.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_language
    sign_in users(:user1)
    old_count = Language.count
    post :create, :language => { }
    assert_equal old_count, Language.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_language
    sign_in users(:librarian1)
    old_count = Language.count
    post :create, :language => { }
    assert_equal old_count, Language.count
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_language_without_name
    sign_in users(:admin)
    old_count = Language.count
    post :create, :language => { }
    assert_equal old_count, Language.count
    
    assert_response :success
  end

  def test_admin_should_create_language
    sign_in users(:admin)
    old_count = Language.count
    post :create, :language => {:name => 'test'}
    assert_equal old_count+1, Language.count
    
    assert_redirected_to language_url(assigns(:language))
  end

  def test_guest_should_show_language
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_language
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_language
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_language
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
  
  def test_guest_should_not_update_language
    put :update, :id => 1, :language => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_language
    sign_in users(:user1)
    put :update, :id => 1, :language => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_language
    sign_in users(:librarian1)
    put :update, :id => 1, :language => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_language_without_name
    sign_in users(:admin)
    put :update, :id => 1, :language => {:name => nil}
    assert_response :success
  end
  
  def test_admin_should_update_language
    sign_in users(:admin)
    put :update, :id => 1, :language => { }
    assert_redirected_to language_url(assigns(:language))
  end
  
  def test_guest_should_not_destroy_language
    old_count = Language.count
    delete :destroy, :id => 1
    assert_equal old_count, Language.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_language
    sign_in users(:user1)
    old_count = Language.count
    delete :destroy, :id => 1
    assert_equal old_count, Language.count
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_language
    sign_in users(:librarian1)
    old_count = Language.count
    delete :destroy, :id => 1
    assert_equal old_count, Language.count
    
    assert_response :forbidden
  end

  def test_admin_should_destroy_language
    sign_in users(:admin)
    old_count = Language.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Language.count
    
    assert_redirected_to languages_url
  end
end
