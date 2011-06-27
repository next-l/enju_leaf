require 'test_helper'

class ImportRequestsControllerTest < ActionController::TestCase
  setup do
    @import_request = import_requests(:one)
  end

  test "guest should not create import_request" do
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create import_request" do
    sign_in users(:user1)
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes
    end

    assert_response :forbidden
  end

  test "librarian should not create import_request without isbn" do
    sign_in users(:librarian1)
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => {:isbn => ''}
    end

    assert_response :success
  end

  test "librarian should not create import_request with invalid isbn" do
    sign_in users(:librarian1)
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => {:isbn => 'invalid'}
    end

    assert_response :success
  end

  test "librarian should create import_request with valid isbn" do
    sign_in users(:librarian1)
    assert_difference('ImportRequest.count') do
      post :create, :import_request => @import_request.attributes.merge(:isbn => '978-4274068096')
    end

    assert_redirected_to new_import_request_path
  end

  test "librarian should not create import_request already imported" do
    sign_in users(:librarian1)
    assert_no_difference('ImportRequest.count') do
      post :create, :import_request => {:isbn => manifestations(:manifestation_00001).isbn}
    end

    assert_response :success
  end

  test "guest should not show import_request" do
    get :show, :id => @import_request.to_param
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not show import_request" do
    sign_in users(:user1)
    get :show, :id => @import_request.to_param
    assert_response :forbidden
  end

  test "librarian should show import_request" do
    sign_in users(:librarian1)
    get :show, :id => @import_request.to_param
    assert_response :success
  end

  test "guest should not update import_request" do
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_redirected_to new_user_session_url
  end

  test "user should not update import_request" do
    sign_in users(:user1)
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_response :forbidden
  end

  test "librarian should update import_request" do
    sign_in users(:librarian1)
    put :update, :id => @import_request.to_param, :import_request => @import_request.attributes
    assert_redirected_to import_request_path(assigns(:import_request))
  end
end
