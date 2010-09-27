require 'test_helper'

class ExemplifiesControllerTest < ActionController::TestCase
  fixtures :exemplifies, :items, :manifestations, :patrons, :users,
    :carrier_types, :circulation_statuses

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:exemplifies)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:exemplifies)
  end

  def test_guest_should_get_index_with_item_id
    get :index, :item_id => 1
    assert_response :success
    assert assigns(:exemplifies)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:exemplifies)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:exemplifies)
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
  
  def test_guest_should_not_create_exemplify
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :manifestation_id => 1, :item_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_exemplify
    sign_in users(:user1)
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :manifestation_id => 1, :item_id => 1 }
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_exemplify_without_manifestation_id
    sign_in users(:librarian1)
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :item_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_exemplify_without_item_id
    sign_in users(:librarian1)
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :manifestation_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_exemplify_already_created
    sign_in users(:librarian1)
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :manifestation_id => 1, :item_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_not_create_exemplify_directly
    sign_in users(:librarian1)
    assert_no_difference('Exemplify.count') do
      post :create, :exemplify => { :manifestation_id => 1, :item_id => 20 }
    end
    
    assert_response :success
    #assert_redirected_to exemplify_url(assigns(:exemplify))
  end

  def test_guest_should_show_exemplify
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_exemplify
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_exemplify
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
    get :edit, :id => 1, :manifestation_id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1, :manifestation_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_exemplify
    put :update, :id => 1, :exemplify => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_exemplify
    sign_in users(:user1)
    put :update, :id => 1, :exemplify => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_exemplify_without_manifestation_id
    sign_in users(:librarian1)
    put :update, :id => 1, :exemplify => {:manifestation_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_exemplify_without_item_id
    sign_in users(:librarian1)
    put :update, :id => 1, :exemplify => {:item_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_exemplify
    sign_in users(:librarian1)
    put :update, :id => 1, :exemplify => { }
    assert_redirected_to exemplify_url(assigns(:exemplify))
  end
  
  def test_librarian_should_update_exemplify_with_position
    sign_in users(:librarian1)
    put :update, :id => 1, :exemplify => { }, :manifestation_id => 1, :position => 1
    assert_redirected_to manifestation_exemplifies_url(assigns(:manifestation))
  end
  
  def test_guest_should_not_destroy_exemplify
    assert_no_difference('Exemplify.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_exemplify
    sign_in users(:user1)
    assert_no_difference('Exemplify.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_exemplify
    sign_in users(:librarian1)
    assert_difference('Exemplify.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to exemplifies_url
  end

  def test_librarian_should_destroy_exemplify_with_manifestation_id
    sign_in users(:librarian1)
    assert_difference('Exemplify.count', -1) do
      delete :destroy, :id => 1, :manifestation_id => 1
    end
    
    assert_redirected_to manifestation_items_url(assigns(:manifestation))
  end

end
