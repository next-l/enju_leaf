require 'test_helper'

class LibraryGroupsControllerTest < ActionController::TestCase
    fixtures :library_groups, :users, :libraries

  def test_guest_should_not_destroy_library_group
    assert_no_difference('LibraryGroup.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_library_group
    sign_in users(:user1)
    assert_no_difference('LibraryGroup.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_library_group
    sign_in users(:librarian1)
    assert_no_difference('LibraryGroup.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_destroy_library_group
    sign_in users(:admin)
    assert_no_difference('LibraryGroup.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
    #assert_redirected_to library_groups_url
  end
end
