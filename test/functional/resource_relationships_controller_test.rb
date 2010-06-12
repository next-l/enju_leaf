require 'test_helper'

class ResourceRelationshipsControllerTest < ActionController::TestCase
  setup do
    @resource_relationship = resource_relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_relationships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_relationship" do
    assert_difference('ResourceRelationship.count') do
      post :create, :resource_relationship => @resource_relationship.attributes
    end

    assert_redirected_to resource_relationship_path(assigns(:resource_relationship))
  end

  test "should show resource_relationship" do
    get :show, :id => @resource_relationship.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @resource_relationship.to_param
    assert_response :success
  end

  test "should update resource_relationship" do
    put :update, :id => @resource_relationship.to_param, :resource_relationship => @resource_relationship.attributes
    assert_redirected_to resource_relationship_path(assigns(:resource_relationship))
  end

  test "should destroy resource_relationship" do
    assert_difference('ResourceRelationship.count', -1) do
      delete :destroy, :id => @resource_relationship.to_param
    end

    assert_redirected_to resource_relationships_path
  end
end
