require 'test_helper'

class ProducesControllerTest < ActionController::TestCase
    fixtures :produces, :manifestations, :patrons, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:produces)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:produces)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:produces)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:produces)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:produces)
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
  
  def test_guest_should_not_create_produce
    assert_no_difference('Produce.count') do
      post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_produce
    assert_no_difference('Produce.count') do
      post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_not_create_produce_already_created
    sign_in users(:librarian1)
    assert_no_difference('Produce.count') do
      post :create, :produce => { :patron_id => 1, :manifestation_id => 1 }
    end
    
    assert_response :success
  end

  def test_librarian_should_create_produce_not_created_yet
    sign_in users(:librarian1)
    assert_difference('Produce.count') do
      post :create, :produce => { :patron_id => 1, :manifestation_id => 10 }
    end
    
    assert_redirected_to produce_url(assigns(:produce))
    assigns(:produce).patron.remove_from_index!
    assigns(:produce).manifestation.remove_from_index!
  end

  def test_guest_should_show_produce
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_produce
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_produce
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
  
  def test_guest_should_not_update_produce
    put :update, :id => 1, :produce => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_produce
    sign_in users(:user1)
    put :update, :id => 1, :produce => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_produce_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => 1, :produce => {:patron_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_not_update_produce_without_manifestation_id
    sign_in users(:librarian1)
    put :update, :id => 1, :produce => {:manifestation_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_produce
    sign_in users(:librarian1)
    put :update, :id => 1, :produce => { }
    assert_redirected_to produce_url(assigns(:produce))
  end
  
  def test_librarian_should_update_produce_with_position
    sign_in users(:librarian1)
    put :update, :id => 1, :produce => { }, :position => 2, :manifestation_id => 1
    assert_redirected_to manifestation_produces_url(assigns(:manifestation))
  end
  
  def test_guest_should_not_destroy_produce
    assert_no_difference('Produce.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_produce
    sign_in users(:user1)
    assert_no_difference('Produce.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_produce
    sign_in users(:librarian1)
    assert_difference('Produce.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to produces_url
  end
end
