require 'test_helper'

class PatronImportResultsControllerTest < ActionController::TestCase
  fixtures :patron_import_results, :users, :roles

  setup do
    @patron_import_result = patron_import_results(:one)
  end

  test "guest should not get index" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
    assert_equal assigns(:patron_import_results), []
  end

  test "user should not get index" do
    sign_in users(:user1)
    get :index
    assert_response :forbidden
    assert_equal assigns(:patron_import_results), []
  end

  test "librarian should not get index" do
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert_not_nil assigns(:patron_import_results)
  end

  test "admin should not get new" do
    sign_in users(:admin)
    get :new
    assert_response :forbidden
  end

  test "admin should create patron_import_result" do
    sign_in users(:admin)
    assert_no_difference('PatronImportResult.count') do
      post :create, :patron_import_result => @patron_import_result.attributes
    end

    assert_response :forbidden
  end

  test "guest should not show patron_import_result" do
    get :show, :id => @patron_import_result.to_param
    assert_redirected_to new_user_session_url
  end

  test "user should not show patron_import_result" do
    sign_in users(:user1)
    get :show, :id => @patron_import_result.to_param
    assert_response :forbidden
  end

  test "librarian should show patron_import_result" do
    sign_in users(:librarian1)
    get :show, :id => @patron_import_result.to_param
    assert_response :success
  end

  test "admin should not get edit" do
    sign_in users(:admin)
    get :edit, :id => @patron_import_result.to_param
    assert_response :forbidden
  end

  test "admin should not update patron_import_result" do
    sign_in users(:admin)
    put :update, :id => @patron_import_result.to_param, :patron_import_result => @patron_import_result.attributes
    assert_response :forbidden
  end

  test "admin should not destroy patron_import_result" do
    sign_in users(:librarian1)
    assert_no_difference('PatronImportResult.count') do
      delete :destroy, :id => @patron_import_result.to_param
    end

    assert_response :forbidden
  end
end
