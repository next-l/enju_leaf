require 'test_helper'

class SubjectsControllerTest < ActionController::TestCase
  fixtures :subjects, :users, :manifestations, :work_has_subjects

  def test_admin_should_get_edit_with_work
    sign_in users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :work_id => 1
    assert_response :success
  end
  
  def test_admin_should_not_get_edit_with_missing_work
    sign_in users(:admin)
    get :edit, :id => subjects(:subject_00001).to_param, :work_id => 100
    assert_response :missing
  end
end
