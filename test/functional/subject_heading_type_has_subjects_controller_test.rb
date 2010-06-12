require 'test_helper'

class SubjectHeadingTypeHasSubjectsControllerTest < ActionController::TestCase
    fixtures :subject_heading_type_has_subjects, :subjects, :subject_types, :subject_heading_types, :users

  test "guest should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subject_heading_type_has_subjects)
  end

  test "guest should not get new" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get new" do
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end

  test "librarian should not get new" do
    sign_in users(:librarian1)
    get :new
    assert_response :forbidden
  end

  test "admin should get new" do
    sign_in users(:admin)
    get :new
    assert_response :success
  end

  test "guest should not create subject_heading_type_has_subject" do
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      post :create, :subject_heading_type_has_subject => {:subject_heading_type_id => 1, :subject_id => 3}
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not create subject_heading_type_has_subject" do
    sign_in users(:user1)
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      post :create, :subject_heading_type_has_subject => {:subject_heading_type_id => 1, :subject_id => 3}
    end

    assert_response :forbidden
  end

  test "librarian should not create subject_heading_type_has_subject" do
    sign_in users(:librarian1)
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      post :create, :subject_heading_type_has_subject => {:subject_heading_type_id => 1, :subject_id => 3}
    end

    assert_response :forbidden
  end

  test "admin should create subject_heading_type_has_subject" do
    sign_in users(:admin)
    assert_difference('SubjectHeadingTypeHasSubject.count') do
      post :create, :subject_heading_type_has_subject => {:subject_heading_type_id => 1, :subject_id => 3}
    end

    assert_redirected_to subject_heading_type_has_subject_path(assigns(:subject_heading_type_has_subject))
  end

  test "guest should show subject_heading_type_has_subject" do
    get :show, :id => subject_heading_type_has_subjects(:one).id
    assert_response :success
  end

  test "guest should not get edit" do
    get :edit, :id => subject_heading_type_has_subjects(:one).id
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "user should not get edit" do
    sign_in users(:user1)
    get :edit, :id => subject_heading_type_has_subjects(:one).id
    assert_response :forbidden
  end

  test "librarian should get edit" do
    sign_in users(:librarian1)
    get :edit, :id => subject_heading_type_has_subjects(:one).id
    assert_response :forbidden
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get :edit, :id => subject_heading_type_has_subjects(:one).id
    assert_response :success
  end

  test "guest should not update subject_heading_type_has_subject" do
    put :update, :id => subject_heading_type_has_subjects(:one).id, :subject_heading_type_has_subject => { }
    assert_redirected_to new_user_session_url
  end

  test "user should not update subject_heading_type_has_subject" do
    sign_in users(:user1)
    put :update, :id => subject_heading_type_has_subjects(:one).id, :subject_heading_type_has_subject => { }
    assert_response :forbidden
  end

  test "librarian should not update subject_heading_type_has_subject" do
    sign_in users(:librarian1)
    put :update, :id => subject_heading_type_has_subjects(:one).id, :subject_heading_type_has_subject => { }
    assert_response :forbidden
  end

  test "admin should update subject_heading_type_has_subject" do
    sign_in users(:admin)
    put :update, :id => subject_heading_type_has_subjects(:one).id, :subject_heading_type_has_subject => { }
    assert_redirected_to subject_heading_type_has_subject_path(assigns(:subject_heading_type_has_subject))
  end

  test "guest should not destroy subject_heading_type_has_subject" do
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      delete :destroy, :id => subject_heading_type_has_subjects(:one).id
    end

    assert_redirected_to new_user_session_url
  end

  test "user should not destroy subject_heading_type_has_subject" do
    sign_in users(:user1)
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      delete :destroy, :id => subject_heading_type_has_subjects(:one).id
    end

    assert_response :forbidden
  end

  test "librarian should not destroy subject_heading_type_has_subject" do
    sign_in users(:librarian1)
    assert_no_difference('SubjectHeadingTypeHasSubject.count') do
      delete :destroy, :id => subject_heading_type_has_subjects(:one).id
    end

    assert_response :forbidden
  end

  test "admin should destroy subject_heading_type_has_subject" do
    sign_in users(:admin)
    assert_difference('SubjectHeadingTypeHasSubject.count', -1) do
      delete :destroy, :id => subject_heading_type_has_subjects(:one).id
    end

    assert_redirected_to subject_heading_type_has_subjects_path
  end
end
