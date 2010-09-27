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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manifestation_relationship" do
    assert_difference('ManifestationRelationship.count') do
      post :create, :manifestation_relationship => @manifestation_relationship.attributes
    end

    assert_redirected_to manifestation_relationship_path(assigns(:manifestation_relationship))
  end

  test "should show manifestation_relationship" do
    get :show, :id => @manifestation_relationship.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @manifestation_relationship.to_param
    assert_response :success
  end

  test "should update manifestation_relationship" do
    put :update, :id => @manifestation_relationship.to_param, :manifestation_relationship => @manifestation_relationship.attributes
    assert_redirected_to manifestation_relationship_path(assigns(:manifestation_relationship))
  end

  test "should destroy manifestation_relationship" do
    assert_difference('ManifestationRelationship.count', -1) do
      delete :destroy, :id => @manifestation_relationship.to_param
    end

    assert_redirected_to manifestation_relationships_path
  end
end
