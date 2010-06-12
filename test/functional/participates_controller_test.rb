require 'test_helper'

class ParticipatesControllerTest < ActionController::TestCase
    fixtures :participates

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_nil assigns(:participates)
  end

  test "user should not get index" do
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_nil assigns(:participates)
  end

  test "librarian should get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:participates)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should get not new" do
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create participate" do
    assert_no_difference('Participate.count') do
      post :create, :participate => { }
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create participate" do
    sign_in users(:user1)
    assert_no_difference('Participate.count') do
      post :create, :participate => { }
    end

    assert_response :forbidden
  end

  test "librarian should create participate" do
    sign_in users(:librarian1)
    assert_difference('Participate.count') do
      post :create, :participate => {:event_id => 1, :patron_id => 3}
    end

    assert_redirected_to participate_path(assigns(:participate))
  end

  test "guest should not show participate" do
    get :show, :id => participates(:one).to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should show participate" do
    sign_in users(:user1)
    get :show, :id => participates(:one).to_param
    assert_response :forbidden
  end

  test "librarian should show participate" do
    sign_in users(:librarian1)
    get :show, :id => participates(:one).to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => participates(:one).to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => participates(:one).to_param
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => participates(:one).to_param
    assert_response :success
  end

  test "guest should not update participate" do
    put :update, :id => participates(:one).to_param, :participate => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update participate" do
    sign_in users(:user1)
    put :update, :id => participates(:one).to_param, :participate => { }
    assert_response :forbidden
  end

  test "librarian should update participate" do
    sign_in users(:librarian1)
    put :update, :id => participates(:one).to_param, :participate => { }
    assert_redirected_to participate_path(assigns(:participate))
  end

  test "guest should not destroy participate" do
    assert_no_difference('Participate.count') do
      delete :destroy, :id => participates(:one).to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy participate" do
    sign_in users(:user1)
    assert_no_difference('Participate.count') do
      delete :destroy, :id => participates(:one).to_param
    end

    assert_response :forbidden
  end

  test "librarian should destroy participate" do
    sign_in users(:librarian1)
    assert_difference('Participate.count', -1) do
      delete :destroy, :id => participates(:one).to_param
    end

    assert_redirected_to participates_path
  end
end
