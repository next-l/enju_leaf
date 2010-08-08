require 'test_helper'

class RealizesControllerTest < ActionController::TestCase
    fixtures :realizes, :resources, :patrons, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:realizes)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:realizes)
  end

  def test_guest_should_get_index_with_expression_id
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:realizes)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:realizes)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:realizes)
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
  
  def test_guest_should_not_create_realize
    assert_no_difference('Realize.count') do
      post :create, :realize => { :patron_id => 1, :expression_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_realize
    assert_no_difference('Realize.count') do
      post :create, :realize => { :patron_id => 1, :expression_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_realize_without_patron_id
    sign_in users(:librarian1)
    assert_no_difference('Realize.count') do
      post :create, :realize => { :expression_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_realize_without_expression_id
    sign_in users(:librarian1)
    assert_no_difference('Realize.count') do
      post :create, :realize => { :patron_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_realize_already_created
    sign_in users(:librarian1)
    assert_no_difference('Realize.count') do
      post :create, :realize => { :patron_id => 1, :expression_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_realize_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Realize.count') do
      post :create, :realize => { :patron_id => 1, :expression_id => 3 }
    end
    
    assert_redirected_to realize_url(assigns(:realize))
  end

  def test_guest_should_show_realize
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_realize
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_realize
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
  
  def test_guest_should_not_update_realize
    put :update, :id => 1, :realize => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_realize
    sign_in users(:user1)
    put :update, :id => 1, :realize => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_realize_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => 1, :realize => {:patron_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_realize_without_expression_id
    sign_in users(:librarian1)
    put :update, :id => 1, :realize => {:expression_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_realize
    sign_in users(:librarian1)
    put :update, :id => 1, :realize => { }
    assert_redirected_to realize_url(assigns(:realize))
  end
  
  def test_librarian_should_update_realize_with_position
    sign_in users(:librarian1)
    put :update, :id => 1, :realize => { }, :expression_id => 1, :position => 1
    assert_redirected_to expression_realizes_url(assigns(:expression))
  end
  
  def test_guest_should_not_destroy_realize
    assert_no_difference('Realize.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_realize
    sign_in users(:user1)
    assert_no_difference('Realize.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_realize
    sign_in users(:librarian1)
    assert_difference('Realize.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to realizes_url
  end

  def test_librarian_should_destroy_realize_with_patron_id
    sign_in users(:librarian1)
    assert_difference('Realize.count', -1) do
      delete :destroy, :id => 1, :patron_id => 1
    end
    
    assert_redirected_to patron_expressions_url(assigns(:patron))
  end

  def test_librarian_should_destroy_realize_with_expression_id
    sign_in users(:librarian1)
    assert_difference('Realize.count', -1) do
      delete :destroy, :id => 1, :expression_id => 1
    end
    
    assert_redirected_to expression_patrons_url(assigns(:expression))
  end
end
