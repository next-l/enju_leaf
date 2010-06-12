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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create patron_relationship" do
    assert_difference('PatronRelationship.count') do
      post :create, :patron_relationship => @patron_relationship.attributes
    end

    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "should show patron_relationship" do
    get :show, :id => @patron_relationship.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @patron_relationship.to_param
    assert_response :success
  end

  test "should update patron_relationship" do
    put :update, :id => @patron_relationship.to_param, :patron_relationship => @patron_relationship.attributes
    assert_redirected_to patron_relationship_path(assigns(:patron_relationship))
  end

  test "should destroy patron_relationship" do
    assert_difference('PatronRelationship.count', -1) do
      delete :destroy, :id => @patron_relationship.to_param
    end

    assert_redirected_to patron_relationships_path
  end
end
