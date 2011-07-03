require 'test_helper'

class ImportRequestsControllerTest < ActionController::TestCase
  setup do
    @import_request = import_requests(:one)
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
end
