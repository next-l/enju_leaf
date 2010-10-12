require 'test_helper'

class ManifestationRelationshipsControllerTest < ActionController::TestCase
  setup do
    @manifestation_relationship = manifestation_relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manifestation_relationships)
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

  test "guest should not create manifestation_relationship" do
    assert_no_difference('ManifestationRelationship.count') do
      post :create, :manifestation_relationship => @manifestation_relationship.attributes
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create manifestation_relationship" do
    sign_in users(:user1)
    assert_no_difference('ManifestationRelationship.count') do
      post :create, :manifestation_relationship => @manifestation_relationship.attributes
    end

    assert_response :forbidden
  end

  test "librarian should create manifestation_relationship" do
    sign_in users(:librarian1)
    assert_difference('ManifestationRelationship.count') do
      post :create, :manifestation_relationship => @manifestation_relationship.attributes
    end

    assert_redirected_to manifestation_relationship_path(assigns(:manifestation_relationship))
  end

  test "guest should show manifestation_relationship" do
    get :show, :id => @manifestation_relationship.to_param
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => @manifestation_relationship.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => @manifestation_relationship.to_param
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => @manifestation_relationship.to_param
    assert_response :success
  end

  test "guest should not update manifestation_relationship" do
    put :update, :id => @manifestation_relationship.to_param, :manifestation_relationship => @manifestation_relationship.attributes
    assert_redirected_to new_user_session_url
  end

  test "user should not update manifestation_relationship" do
    sign_in users(:user1)
    put :update, :id => @manifestation_relationship.to_param, :manifestation_relationship => @manifestation_relationship.attributes
    assert_response :forbidden
  end

  test "librarian should update manifestation_relationship" do
    sign_in users(:librarian1)
    put :update, :id => @manifestation_relationship.to_param, :manifestation_relationship => @manifestation_relationship.attributes
    assert_redirected_to manifestation_relationship_path(assigns(:manifestation_relationship))
  end

  test "guest should not destroy manifestation_relationship" do
    assert_no_difference('ManifestationRelationship.count') do
      delete :destroy, :id => @manifestation_relationship.to_param
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy manifestation_relationship" do
    sign_in users(:user1)
    assert_no_difference('ManifestationRelationship.count') do
      delete :destroy, :id => @manifestation_relationship.to_param
    end

    assert_response :forbidden
  end

  test "librarian should destroy manifestation_relationship" do
    sign_in users(:librarian1)
    assert_difference('ManifestationRelationship.count', -1) do
      delete :destroy, :id => @manifestation_relationship.to_param
    end

    assert_redirected_to manifestation_relationships_path
  end
end
