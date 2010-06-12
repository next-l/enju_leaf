require 'test_helper'

class DonatesControllerTest < ActionController::TestCase
  fixtures :donates, :users, :items

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:donates)
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:donates)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:donates)
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

  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  def test_guest_should_not_create_donate
    assert_no_difference('Donate.count') do
      post :create, :donate => { }
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_donate
    sign_in users(:user1)
    assert_no_difference('Donate.count') do
      post :create, :donate => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_not_create_donate_without_patron_id
    sign_in users(:librarian1)
    assert_no_difference('Donate.count') do
      post :create, :donate => {:item_id => 6}
    end

    assert_response :success
  end

  def test_librarian_should_not_create_donate_without_item_id
    sign_in users(:librarian1)
    assert_no_difference('Donate.count') do
      post :create, :donate => {:patron_id => 1}
    end

    assert_response :success
  end

  def test_librarian_should_create_donate
    sign_in users(:librarian1)
    assert_difference('Donate.count') do
      post :create, :donate => {:patron_id => 1, :item_id => 6}
    end

    assert_redirected_to donate_url(assigns(:donate))
  end

  def test_guest_should_not_show_donate
    get :show, :id => donates(:donate_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_show_donate
    sign_in users(:user1)
    get :show, :id => donates(:donate_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_show_donate
    sign_in users(:librarian1)
    get :show, :id => donates(:donate_00001).id
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => donates(:donate_00001).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => donates(:donate_00001).id
    assert_response :forbidden
  end

  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => donates(:donate_00001).id
    assert_response :success
  end

  def test_guest_should_not_update_donate
    put :update, :id => donates(:donate_00001).id, :donate => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_donate
    sign_in users(:user1)
    put :update, :id => donates(:donate_00001).id, :donate => { }
    assert_response :forbidden
  end

  def test_librarian_should_not_update_donate_without_patron_id
    sign_in users(:librarian1)
    put :update, :id => donates(:donate_00001).id, :donate => {:patron_id => nil}
    assert_response :success
  end

  def test_librarian_should_not_update_donate_without_item_id
    sign_in users(:librarian1)
    put :update, :id => donates(:donate_00001).id, :donate => {:item_id => nil}
    assert_response :success
  end

  def test_librarian_should_update_donate
    sign_in users(:librarian1)
    put :update, :id => donates(:donate_00001).id, :donate => {:item_id => 3, :patron_id => 2}
    assert_redirected_to donate_url(assigns(:donate))
  end

  def test_guest_should_not_destroy_donate
    assert_no_difference('Donate.count') do
      delete :destroy, :id => donates(:donate_00001).id
    end

    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_donate
    sign_in users(:user1)
    assert_no_difference('Donate.count') do
      delete :destroy, :id => donates(:donate_00001).id
    end

    assert_response :forbidden
  end

  def test_librarian_should_destroy_donate
    sign_in users(:librarian1)
    assert_difference('Donate.count', -1) do
      delete :destroy, :id => donates(:donate_00001).id
    end

    assert_redirected_to donates_url
  end
end
