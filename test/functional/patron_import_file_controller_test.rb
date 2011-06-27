# -*- encoding: utf-8 -*-
require 'test_helper'

class PatronImportFilesControllerTest < ActionController::TestCase
  fixtures :patron_import_files, :users, :roles, :patrons,
    :user_groups, :libraries, :library_groups, :patron_types, :languages,
    :events, :event_categories

  def test_guest_should_not_create_patron_import_file
    assert_no_difference('PatronImportFile.count') do
      post :create, :patron_import_file => { }
    end

    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_patron_import_file
    sign_in users(:user1)
    assert_no_difference('PatronImportFile.count') do
      post :create, :patron_import_file => { }
    end

    assert_response :forbidden
  end

  def test_librarian_should_create_patron_import_file
    sign_in users(:librarian1)
    old_patrons_count = Patron.count
    old_import_results_count = PatronImportResult.count
    assert_difference('PatronImportFile.count') do
      post :create, :patron_import_file => {:patron_import => fixture_file_upload("../../examples/patron_import_file_sample1.tsv", 'text/csv') }
    end
    assert_difference('Patron.count', 3) do
      assigns(:patron_import_file).import_start
    end
    assert_equal '原田 ushi 隆史', Patron.order('id DESC')[0].full_name
    assert_equal '田辺浩介', Patron.order('id DESC')[1].full_name
    assert_equal Time.zone.parse('1978-01-01'), Patron.order('id DESC')[2].date_of_birth
    assert_equal old_patrons_count + 3, Patron.count
    assert_equal old_import_results_count + 4, PatronImportResult.count

    assert_equal 'librarian1', assigns(:patron_import_file).user.username
    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end

  def test_librarian_should_create_patron_import_file_written_in_shift_jis
    sign_in users(:librarian1)
    old_patrons_count = Patron.count
    old_import_results_count = PatronImportResult.count
    assert_difference('PatronImportFile.count') do
      post :create, :patron_import_file => {:patron_import => fixture_file_upload("../../examples/patron_import_file_sample3.tsv", 'text/csv') }
    end
    assert_difference('Patron.count', 4) do
      assigns(:patron_import_file).import_start
    end
    assert_equal '原田 ushi 隆史', Patron.order('id DESC')[0].full_name
    assert_equal '田辺浩介', Patron.order('id DESC')[1].full_name
    assert_equal 'fugafuga@example.jp', Patron.order('id DESC')[2].email
    assert_equal Role.find_by_name('Guest'), Patron.order('id DESC')[3].required_role
    assert_nil Patron.order('id DESC')[1].email
    assert_equal old_import_results_count + 5, PatronImportResult.count

    assert_equal 'librarian1', assigns(:patron_import_file).user.username
    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end

  def test_librarian_should_import_user
    sign_in users(:librarian1)
    old_patrons_count = Patron.count
    assert_difference('PatronImportFile.count') do
      post :create, :patron_import_file => {:patron_import => fixture_file_upload("../../examples/patron_import_file_sample2.tsv", 'text/csv') }
    end
    assert_difference('User.count', 4) do
      assigns(:patron_import_file).import_start
    end
    assert_equal old_patrons_count + 7, Patron.count

    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end

  def test_guest_should_not_update_patron_import_file
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_update_patron_import_file
    sign_in users(:user1)
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_response :forbidden
  end

  def test_librarian_should_update_patron_import_file
    sign_in users(:librarian1)
    put :update, :id => patron_import_files(:patron_import_file_00003).id, :patron_import_file => { }
    assert_redirected_to patron_import_file_path(assigns(:patron_import_file))
  end
end
