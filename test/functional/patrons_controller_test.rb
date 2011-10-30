require 'test_helper'

class PatronsControllerTest < ActionController::TestCase
  fixtures :patrons, :users, :patron_types, :manifestations, :carrier_types,
    :roles, :creates, :realizes, :produces, :owns, :languages, :countries,
    :patron_relationships, :patron_relationship_types

  def test_guest_should_get_index_with_query
    get :index, :query => 'Librarian1'
    assert_response :success
  end

  def test_guest_should_get_index_with_patron
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:patrons)
  end

  def test_guest_should_get_index_with_manifestation
    get :index, :manifestation_id => 1
    assert_response :success
  end

  def test_guest_should_not_show_patron_when_required_role_is_user
    get :show, :id => 5
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_show_patron
    sign_in users(:user1)
    get :show, :id => users(:user2).patron
    assert_response :success
  end

  def test_user_should_not_show_patron_when_required_role_is_librarian
    sign_in users(:user2)
    get :show, :id => users(:user1).patron
    assert_response :forbidden
  end

  def test_user_should_show_myself
    sign_in users(:user1)
    get :show, :id => users(:user1).patron
    assert_response :success
  end

  def test_librarian_should_not_show_patron_when_required_role_is_admin
    sign_in users(:librarian2)
    get :show, :id => users(:librarian1).patron
    assert_response :forbidden
  end

  def test_librarian_should_not_show_patron_not_create
    sign_in users(:librarian1)
    get :show, :id => 3, :work_id => 3
    assert_response :missing
    #assert_redirected_to new_patron_create_url(assigns(:patron), :work_id => 3)
  end

  def test_librarian_should_not_show_patron_not_realize
    sign_in users(:librarian1)
    get :show, :id => 4, :expression_id => 4
    assert_response :missing
  end

  def test_librarian_should_not_show_patron_not_produce
    sign_in users(:librarian1)
    get :show, :id => 4, :manifestation_id => 4
    assert_response :missing
    #assert_redirected_to new_patron_produce_url(assigns(:patron), :manifestation_id => 4)
  end

  def test_user_should_get_edit_myself
    sign_in users(:user1)
    get :edit, :id => users(:user1).patron
    assert_response :success
  end
  
  def test_user_should_not_get_edit_other_patron
    sign_in users(:user1)
    get :edit, :id => users(:user2).patron
    assert_response :forbidden
  end

  def test_librarian_should_edit_patron_when_required_role_is_user
    sign_in users(:librarian1)
    get :edit, :id => users(:user2).patron
    assert_response :success
  end

  def test_librarian_should_edit_patron_when_required_role_is_librarian
    sign_in users(:librarian1)
    get :edit, :id => users(:user1).patron
    assert_response :success
  end
  
  def test_librarian_should_not_get_edit_admin
    sign_in users(:librarian1)
    get :edit, :id => users(:admin).patron
    assert_response :forbidden
  end
  
  def test_user_should_not_destroy_patron
    sign_in users(:user1)
    assert_no_difference('Patron.count') do
      delete :destroy, :id => users(:user1).patron
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_patron
    sign_in users(:librarian1)
    assert_difference('Patron.count', -1) do
      delete :destroy, :id => users(:user1).patron
    end
    
    assert_redirected_to patrons_url
  end

  def test_librarian_should_not_destroy_librarian
    sign_in users(:librarian1)
    assert_no_difference('Patron.count') do
      delete :destroy, :id => users(:librarian2).patron
    end
    
    assert_response :forbidden
  end
end
