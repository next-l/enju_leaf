require 'test_helper'

class ManifestationsControllerTest < ActionController::TestCase
  fixtures :manifestations, :carrier_types, :work_has_subjects, :languages, :subjects, :subject_types,
    :form_of_works, :realizes,
    :content_types, :frequencies,
    :items, :library_groups, :libraries, :shelves, :languages,
    :patrons, :user_groups, :users,
    :bookmarks, :roles,
    :subscriptions, :subscribes, :search_histories


  def test_guest_should_get_index
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index
      end
    else
      assert_difference('SearchHistory.count') do
        get :index
      end
    end
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_xml
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :format => 'xml'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :format => 'xml'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_csv
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :format => 'csv'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :format => 'csv'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_user_should_not_create_search_history_if_log_is_written_to_file
    sign_in users(:user1)
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :query => 'test'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :query => 'test'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_expression
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:manifestations)
  end

  #def test_user_should_not_get_index_with_subscription
  #  sign_in users(:user1)
  #  get :index, :subscription_id => 1
  #  assert_response :forbidden
  #end

  #def test_librarian_should_get_index_with_subscription
  #  sign_in users(:librarian1)
  #  get :index, :subscription_id => 1
  #  assert_response :success
  #  assert assigns(:subscription)
  #  assert assigns(:manifestations)
  #end

  def test_guest_should_get_index_with_query
    get :index, :query => '2005'
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_page_number
    get :index, :query => '2005', :number_of_pages_at_least => 1, :number_of_pages_at_most => 100
    assert_response :success
    assert assigns(:manifestations)
    assert_equal '2005 number_of_pages_i: [1 TO 100]', assigns(:query)
  end

  def test_guest_should_get_index_with_pubdate_from
    get :index, :query => '2005', :pubdate_from => '2000'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal '2005 date_of_publication_d: [1999-12-31T15:00:00Z TO *]', assigns(:query)
  end

  def test_guest_should_get_index_with_pubdate_to
    get :index, :query => '2005', :pubdate_to => '2000'
    assert_response :success
    assert assigns(:manifestations)
    assert_equal '2005 date_of_publication_d: [* TO 1999-12-31T15:00:00Z]', assigns(:query)
  end

  def test_guest_should_get_index_all_facet
    get :index, :query => '2005', :view => 'all_facet'
    assert_response :success
    assert assigns(:carrier_type_facet)
    assert assigns(:language_facet)
    assert assigns(:library_facet)
    #assert assigns(:subject_facet)
  end

  def test_guest_should_get_index_carrier_type_facet
    get :index, :query => '2005', :view => 'carrier_type_facet'
    assert_response :success
    assert assigns(:carrier_type_facet)
  end

  def test_guest_should_get_index_language_facet
    get :index, :query => '2005', :view => 'language_facet'
    assert_response :success
    assert assigns(:language_facet)
  end

  def test_guest_should_get_index_library_facet
    get :index, :query => '2005', :view => 'library_facet'
    assert_response :success
    assert assigns(:library_facet)
  end

  #def test_guest_should_get_index_subject_facet
  #  get :index, :query => '2005', :view => 'subject_facet'
  #  assert_response :success
  #  assert assigns(:subject_facet)
  #end

  def test_guest_should_get_index_tag_cloud
    get :index, :query => '2005', :view => 'tag_cloud'
    assert_response :success
    assert_template :partial => '_tag_cloud'
  end

  #def test_user_should_save_search_history_when_allowed
  #  old_search_history_count = SearchHistory.count
  #  sign_in users(:admin)
  #  get :index, :query => '2005'
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count + 1, SearchHistory.count
  #end

  #def test_user_should_not_save_search_history_when_not_allowed
  #  old_search_history_count = SearchHistory.count
  #  sign_in users(:user1)
  #  get :index
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count, SearchHistory.count
  #end

  #def test_user_should_not_get_new
  #  sign_in users(:user1)
  #  get :new
  #  assert_response :forbidden
  #end
  
  #def test_librarian_should_not_get_new_without_expression_id
  #  sign_in users(:librarian1)
  #  get :new
  #  assert_response :redirect
  #  assert_redirected_to expressions_url
  #end
  
  def test_librarian_should_get_new_without_expression_id
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_librarian_should_get_new_with_expression_id
    sign_in users(:librarian1)
    get :new, :expression_id => 1
    assert_response :success
  end
  
  def test_admin_should_get_new_without_expression_id
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_admin_should_get_new_with_expression_id
    sign_in users(:admin)
    get :new, :expression_id => 1
    assert_response :success
  end
  
  def test_guest_should_not_create_manifestation
    assert_no_difference('Manifestation.count') do
      post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1 }
    end
    
    assert_redirected_to new_user_session_url
  end

  #def test_user_should_not_create_manifestation
  #  sign_in users(:user1)
  #  assert_no_difference('Manifestation.count') do
  #    post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1 }
  #  end
  #  
  #  assert_response :forbidden
  #end

  def test_user_should_not_create_manifestation
    sign_in users(:user1)
    assert_no_difference('Manifestation.count') do
      post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1 }
    end
    
    assert_response :forbidden
  end

  #def test_librarian_should_not_create_manifestation_without_expression
  #  sign_in users(:librarian1)
  #  assert_no_difference('Manifestation.count') do
  #   post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }
  #  end
  #  
  #  assert_response :redirect
  #  assert_redirected_to expressions_url
  #  assert_equal 'Specify the expression.', flash[:notice]
  #end

  def test_librarian_should_create_manifestation_without_expression
    sign_in users(:librarian1)
    assert_difference('Manifestation.count') do
      post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }
    end
    
    assert_response :redirect
    assert assigns(:manifestation)
    assert_redirected_to manifestation_url(assigns(:manifestation))
    assigns(:manifestation).remove_from_index!
  end

  def test_librarian_should_not_create_manifestation_without_title
    sign_in users(:librarian1)
    assert_no_difference('Manifestation.count') do
      post :create, :manifestation => { :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    end
    
    assert_response :success
  end

  def test_librarian_should_create_manifestation_with_expression
    sign_in users(:librarian1)
    assert_difference('Manifestation.count') do
      post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    end
    
    assert assigns(:manifestation)
    assert_redirected_to manifestation_url(assigns(:manifestation))
    assigns(:manifestation).remove_from_index!
  end

  def test_admin_should_create_manifestation_with_expression
    sign_in users(:admin)
    assert_difference('Manifestation.count') do
      post :create, :manifestation => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    end
    
    assert assigns(:manifestation)
    assert_redirected_to manifestation_url(assigns(:manifestation))
    assigns(:manifestation).remove_from_index!
  end

  def test_guest_should_show_manifestation_with_holding
    get :show, :id => 1, :mode => 'holding'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_edit
    get :show, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_list
    get :show, :id => 1, :mode => 'tag_list'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_authors
    get :show, :id => 1, :mode => 'show_authors'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_all_authors
    get :show, :id => 1, :mode => 'show_all_authors'
    assert_response :success
  end

  def test_guest_should_not_send_manifestation_detail_email
    get :show, :id => 1, :mode => 'send_email'
    assert_redirected_to new_user_session_url
  end

  def test_user_should_send_manifestation_detail_email
    sign_in users(:user1)
    get :show, :id => 1, :mode => 'send_email'
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_librarian_should_show_manifestation_with_expression_not_embodied
    sign_in users(:librarian1)
    get :show, :id => 1, :expression_id => 3
    assert_response :success
  end

  def test_librarian_should_show_manifestation_with_patron_not_produced
    sign_in users(:librarian1)
    get :show, :id => 3, :patron_id => 1
    assert_response :success
  end

  def test_user_should_get_edit_with_tag_edit
    sign_in users(:user1)
    get :edit, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end
  
  def test_guest_should_not_update_manifestation
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_manifestation
    sign_in users(:user1)
    put :update, :id => 1, :manifestation => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_manifestation_without_title
    sign_in users(:librarian1)
    put :update, :id => 1, :manifestation => { :original_title => nil }
    assert_response :success
  end
  
  def test_librarian_should_update_manifestation
    sign_in users(:librarian1)
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to manifestation_url(assigns(:manifestation))
    assigns(:manifestation).remove_from_index!
  end
  
  def test_admin_should_update_manifestation
    sign_in users(:admin)
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to manifestation_url(assigns(:manifestation))
    assigns(:manifestation).remove_from_index!
  end
  
  def test_guest_should_not_destroy_manifestation
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_manifestation
    sign_in users(:user1)
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_everyone_should_not_destroy_manifestation_contain_items
    sign_in users(:admin)
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_manifestation
    sign_in users(:librarian1)
    assert_difference('Manifestation.count', -1) do
      delete :destroy, :id => 10
    end
    
    assert_redirected_to manifestations_url
  end

  def test_admin_should_destroy_manifestation
    sign_in users(:admin)
    assert_difference('Manifestation.count', -1) do
      delete :destroy, :id => 10
    end
    
    assert_redirected_to manifestations_url
  end
end
