require 'test_helper'

class CreatesControllerTest < ActionController::TestCase
    fixtures :creates, :manifestations, :patrons, :users, :form_of_works, :languages

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:creates)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:creates)
  end

  def test_guest_should_get_index_with_work_id
    get :index, :work_id => 1
    assert_response :success
    assert assigns(:creates)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:creates)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:creates)
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
  
  def test_guest_should_not_create_create
    assert_no_difference('Create.count') do
      post :create, :create => { :patron_id => 1, :work_id => 1 }
    end
    
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_create
    sign_in users(:user1)
    assert_no_difference('Create.count') do
      post :create, :create => { :patron_id => 1, :work_id => 1 }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_create_without_patron_id
    sign_in users(:librarian1)
    assert_no_difference('Create.count') do
      post :create, :create => { :work_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_without_work_id
    sign_in users(:librarian1)
    assert_no_difference('Create.count') do
      post :create, :create => { :patron_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_create_already_created
    sign_in users(:librarian1)
    assert_no_difference('Create.count') do
      post :create, :create => { :patron_id => 1, :work_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_create_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Create.count') do
      post :create, :create => { :patron_id => 1, :work_id => 3 }
    end
    
    assert_redirected_to create_url(assigns(:create))
  end

  def test_guest_should_show_create
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_create
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_create
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
    get :edit, :id => 1, :patron_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :patron_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_create
    put :update, :id => 1, :create => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_create
    sign_in users(:user1)
    put :update, :id => 1, :create => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_create_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => 1, :create => {:patron_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_create_without_work_id
    sign_in users(:librarian1)
    put :update, :id => 1, :create => {:work_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_create
    sign_in users(:librarian1)
    put :update, :id => 1, :create => { }
    assert_redirected_to create_url(assigns(:create))
  end
  
  def test_librarian_should_update_create_with_position
    sign_in users(:librarian1)
    put :update, :id => 1, :create => { }, :position => 2, :work_id => 1
    assert_redirected_to work_creates_url(assigns(:work))
  end
  
  def test_guest_should_not_destroy_create
    assert_no_difference('Create.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_create
    sign_in users(:user1)
    assert_no_difference('Create.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_create
    sign_in users(:librarian1)
    assert_difference('Create.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to creates_url
  end
end
