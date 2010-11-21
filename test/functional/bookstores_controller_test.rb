require 'test_helper'

class BookstoresControllerTest < ActionController::TestCase
    fixtures :bookstores, :users, :patrons, :patron_types, :roles, :languages,
    :libraries, :library_groups, :user_groups

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:bookstores), []
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:bookstores), []
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:bookstores)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  def test_librarian_should_not_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  def test_admin_should_not_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_bookstore
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_bookstore
    sign_in users(:user1)
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_bookstore
    sign_in users(:librarian1)
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :forbidden
  end

  def test_admin_should_not_create_bookstore_without_name
    sign_in users(:admin)
    assert_no_difference('Bookstore.count') do
      post :create, :bookstore => { }
    end

    assert_response :success
  end

  def test_admin_should_not_create_bookstore
    sign_in users(:admin)
    assert_difference('Bookstore.count') do
      post :create, :bookstore => {:name => 'test'}
    end

    assert_redirected_to bookstore_url(assigns(:bookstore))
  end

  def test_guest_should_not_show_bookstore
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_bookstore
    sign_in users(:user1)
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_bookstore
    sign_in users(:librarian1)
    get :show, :id => bookstores(:bookstore_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :forbidden
  end

  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => bookstores(:bookstore_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_bookstore
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_bookstore
    sign_in users(:user1)
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_bookstore
    sign_in users(:librarian1)
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_response :forbidden
  end

  def test_admin_should_not_update_bookstore_without_name
    sign_in users(:admin)
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => {:name => ""}
    assert_response :success
  end

  def test_admin_should_update_bookstore
    sign_in users(:admin)
    put :update, :id => bookstores(:bookstore_00001).id, :bookstore => { }
    assert_redirected_to bookstore_url(assigns(:bookstore))
  end

  test "admin should update bookstore with position" do
    sign_in users(:admin)
    put :update, :id => bookstores(:bookstore_00001), :bookstore => { }, :position => 2
    assert_redirected_to bookstores_path
  end

  def test_guest_should_not_destroy_bookstore
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_bookstore
    sign_in users(:user1)
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_bookstore
    sign_in users(:librarian1)
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_not_destroy_bookstore_contains_order_lists
    sign_in users(:admin)
    assert_no_difference('Bookstore.count') do
      delete :destroy, :id => bookstores(:bookstore_00001).id
    end

    assert_response :forbidden
  end

  def test_admin_should_destroy_bookstore_which_doesnt_contain_order_lists
    sign_in users(:admin)
    assert_difference('Bookstore.count', -1) do
      delete :destroy, :id => bookstores(:bookstore_00004).id
    end

    assert_redirected_to bookstores_url
  end
end
