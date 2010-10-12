require 'test_helper'

class PatronRelationshipsControllerTest < ActionController::TestCase
  setup do
    @patron_relationship = patron_relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_relationships)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end

  test "guest should not create patron_relationship" do
    assert_no_difference('PatronRelationship.count') do
      post :create, :patron_relationship => @patron_relationship.attributes
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create patron_relationship" do
    sign_in users(:user1)
    assert_no_difference('PatronRelationship.count') do
      post :create, :patron_relationship => @patron_relationship.attributes
    end

    assert_response :forbidden
  end

  test "librarian should create patron_relationship" do
    sign_in users(:librarian1)
    assert_difference('PatronRelationship.count') do
      post :create, :patron_relationship => @patron_relationship.attributes
    end

    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "guest should show patron_relationship" do
    get :show, :id => @patron_relationship.to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => @patron_relationship.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => @patron_relationship.to_param
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => @patron_relationship.to_param
    assert_response :success
  end

  test "guest should not update patron_relationship" do
    put :update, :id => @patron_relationship.to_param, :patron_relationship => @patron_relationship.attributes
    assert_redirected_to new_user_session_url
  end

  test "user should not update patron_relationship" do
    sign_in users(:user1)
    put :update, :id => @patron_relationship.to_param, :patron_relationship => @patron_relationship.attributes
    assert_response :forbidden
  end

  test "librarian should update patron_relationship" do
    sign_in users(:librarian1)
    put :update, :id => @patron_relationship.to_param, :patron_relationship => @patron_relationship.attributes
    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "guest should not destroy patron_relationship" do
    assert_no_difference('PatronRelationship.count') do
      delete :destroy, :id => @patron_relationship.to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy patron_relationship" do
    sign_in users(:user1)
    assert_no_difference('PatronRelationship.count') do
      delete :destroy, :id => @patron_relationship.to_param
    end

    assert_response :forbidden
  end

  test "librarian should destroy patron_relationship" do
    sign_in users(:librarian1)
    assert_difference('PatronRelationship.count', -1) do
      delete :destroy, :id => @patron_relationship.to_param
    end

    assert_redirected_to patron_relationships_path
  end
end
