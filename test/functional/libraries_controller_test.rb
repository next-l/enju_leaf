# -*- encoding: utf-8 -*-
require 'test_helper'

class LibrariesControllerTest < ActionController::TestCase
  fixtures :libraries, :users

  def test_admin_should_not_create_library_without_short_display_name
    sign_in users(:admin)
    assert_no_difference('Library.count') do
      post :create, :library => { :name => 'Fujisawa Library', :short_display_name => 'fujisawa' }
    end
    
    assert_response :success
  end

  def test_admin_should_not_update_library_without_name
    sign_in users(:admin)
    put :update, :id => 'kamata', :library => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_not_update_library_without_name
    sign_in users(:admin)
    put :update, :id => 'kamata', :library => {:name => ""}
    assert_response :success
  end
  
  def test_admin_should_update_library_with_position
    sign_in users(:admin)
    put :update, :id => 'kamata', :library => { }, :position => 2
    assert_redirected_to libraries_url
  end
  
  def test_everyone_should_not_destroy_library_id_1
    sign_in users(:admin)
    assert_no_difference('Library.count') do
      delete :destroy, :id => 'web'
    end
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_library_contains_shelves
    sign_in users(:admin)
    assert_no_difference('Library.count') do
      delete :destroy, :id => 'kamata'
    end
    
    assert_response :forbidden
  end
end
