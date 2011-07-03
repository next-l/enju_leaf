require 'test_helper'

class ShelvesControllerTest < ActionController::TestCase
  fixtures :shelves, :users

  def test_guest_should_not_create_shelf
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_shelf
    sign_in users(:user1)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_create_shelf
    sign_in users(:librarian1)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_create_shelf_without_name
    sign_in users(:admin)
    assert_no_difference('Shelf.count') do
      post :create, :shelf => { :name => nil }, :library_id => 'kamata'
    end
    
    assert_response :success
  end

  def test_admin_should_create_shelf
    sign_in users(:admin)
    assert_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }
    end
    assert_equal 'web', assigns(:shelf).library.name
    
    assert_redirected_to shelf_url(assigns(:shelf))
  end

  def test_admin_should_create_shelf_with_library
    sign_in users(:admin)
    assert_difference('Shelf.count') do
      post :create, :shelf => { :name => 'My shelf' }, :library_id => 'kamata'
    end
    assert_equal 'kamata', assigns(:shelf).library.name
    
    assert_redirected_to shelf_url(assigns(:shelf))
  end

  def test_admin_should_update_shelf_with_position
    sign_in users(:admin)
    put :update, :id => 2, :shelf => { }, :position => 2, :library_id => 'kamata'
    assert_redirected_to library_shelves_url(assigns(:library))
  end

  def test_everyone_should_not_destroy_shelf_id_1
    sign_in users(:admin)
    assert_no_difference('Shelf.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
end
