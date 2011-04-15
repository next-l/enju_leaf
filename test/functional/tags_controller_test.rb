require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  fixtures :tags, :users

  def test_guest_should_not_destroy_tag
    assert_no_difference('Tag.count') do
      delete :destroy, :id => 'next-l'
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_tag
    sign_in users(:user1)
    assert_no_difference('Tag.count') do
      delete :destroy, :id => 'next-l'
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_tag
    sign_in users(:librarian1)
    assert_difference('Tag.count', -1) do
      delete :destroy, :id => 'next-l'
    end
    
    assert_redirected_to tags_url
  end
end
