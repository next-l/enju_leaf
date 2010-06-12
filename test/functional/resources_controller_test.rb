require 'test_helper'

class ResourcesControllerTest < ActionController::TestCase
  fixtures :resources, :carrier_types, :work_has_subjects, :languages, :subjects, :subject_types,
    :form_of_works, :realizes,
    :content_types, :frequencies,
    :items, :library_groups, :libraries, :shelves, :languages,
    :patrons, :user_groups, :users,
    :bookmarks, :roles,
    :subscriptions, :subscribes, :search_histories


  def test_api_sru_template
    get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
    assert_response :success
    assert_template('resources/index')
  end

  def test_api_sru_error
    get :index, :format => 'sru'
    assert_response :success
    assert_template('resources/explain')
  end

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
    assert assigns(:resources)
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
    assert assigns(:resources)
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
    assert assigns(:resources)
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
    assert assigns(:resources)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:resources)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:resources)
  end

  def test_guest_should_get_index_with_expression
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:resources)
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
  #  assert assigns(:resources)
  #end

  def test_guest_should_get_index_with_query
    get :index, :query => '2005'
    assert_response :success
    assert assigns(:resources)
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
  #  assert assigns(:resources)
  #  assert_equal old_search_history_count + 1, SearchHistory.count
  #end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:resources)
  end

  #def test_user_should_not_save_search_history_when_not_allowed
  #  old_search_history_count = SearchHistory.count
  #  sign_in users(:user1)
  #  get :index
  #  assert_response :success
  #  assert assigns(:resources)
  #  assert_equal old_search_history_count, SearchHistory.count
  #end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:resources)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:resources)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  #def test_user_should_not_get_new
  #  sign_in users(:user1)
  #  get :new
  #  assert_response :forbidden
  #end
  
  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end
  
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
  
  def test_guest_should_not_create_resource
    old_count = Resource.count
    post :create, :resource => { :original_title => 'test', :carrier_type_id => 1 }
    assert_equal old_count, Resource.count
    
    assert_redirected_to new_user_session_url
  end

  #def test_user_should_not_create_resource
  #  sign_in users(:user1)
  #  assert_no_difference('Resource.count') do
  #    post :create, :resource => { :original_title => 'test', :carrier_type_id => 1 }
  #  end
  #  
  #  assert_response :forbidden
  #end

  def test_user_should_not_create_resource
    sign_in users(:user1)
    assert_no_difference('Resource.count') do
      post :create, :resource => { :original_title => 'test', :carrier_type_id => 1 }
    end
    
    assert_response :forbidden
  end

  #def test_librarian_should_not_create_resource_without_expression
  #  sign_in users(:librarian1)
  #  old_count = Resource.count
  #  post :create, :resource => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }
  #  assert_equal old_count, Resource.count
  #  
  #  assert_response :redirect
  #  assert_redirected_to expressions_url
  #  assert_equal 'Specify the expression.', flash[:notice]
  #end

  def test_librarian_should_create_resource_without_expression
    sign_in users(:librarian1)
    old_count = Resource.count
    post :create, :resource => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }
    assert_equal old_count + 1, Resource.count
    
    assert_response :redirect
    assert assigns(:resource)
    assert_redirected_to resource_url(assigns(:resource))
    assigns(:resource).remove_from_index!
  end

  def test_librarian_should_not_create_resource_without_title
    sign_in users(:librarian1)
    old_count = Resource.count
    post :create, :resource => { :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count, Resource.count
    
    assert_response :success
  end

  def test_librarian_should_create_resource_with_expression
    sign_in users(:librarian1)
    old_count = Resource.count
    post :create, :resource => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count+1, Resource.count
    
    assert assigns(:resource)
    assert_redirected_to resource_url(assigns(:resource))
    assigns(:resource).remove_from_index!
  end

  def test_admin_should_create_resource_with_expression
    sign_in users(:admin)
    old_count = Resource.count
    post :create, :resource => { :original_title => 'test', :carrier_type_id => 1, :language_id => 1 }, :expression_id => 1
    assert_equal old_count+1, Resource.count
    
    assert assigns(:resource)
    assert_redirected_to resource_url(assigns(:resource))
    assigns(:resource).remove_from_index!
  end

  def test_guest_should_show_resource
    get :show, :id => 1
    assert_response :success
  end

  test 'guest shoud show resource screen shot' do
    get :show, :id => 22, :mode => 'screen_shot'
    assert_response :success
  end

  def test_guest_should_show_resource_with_holding
    get :show, :id => 1, :mode => 'holding'
    assert_response :success
  end

  def test_guest_should_show_resource_with_tag_edit
    get :show, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end

  def test_guest_should_show_resource_with_tag_list
    get :show, :id => 1, :mode => 'tag_list'
    assert_response :success
  end

  def test_guest_should_show_resource_with_show_authors
    get :show, :id => 1, :mode => 'show_authors'
    assert_response :success
  end

  def test_guest_should_show_resource_with_show_all_authors
    get :show, :id => 1, :mode => 'show_all_authors'
    assert_response :success
  end

  def test_guest_should_show_resource_with_isbn
    get :show, :isbn => "4798002062"
    assert_response :redirect
    assert_redirected_to resource_url(assigns(:resource))
  end

  def test_guest_should_not_show_resource_with_invalid_isbn
    get :show, :isbn => "47980020620"
    assert_response :missing
  end

  def test_user_should_show_resource
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_resource
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_resource_with_expression_not_embodied
    sign_in users(:librarian1)
    get :show, :id => 1, :expression_id => 3
    assert_response :success
  end

  def test_librarian_should_show_resource_with_patron_not_produced
    sign_in users(:librarian1)
    get :show, :id => 3, :patron_id => 1
    assert_response :success
  end

  def test_admin_should_show_resource
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_get_edit_with_tag_edit
    sign_in users(:user1)
    get :edit, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_librarian_should_get_edit_upload
    sign_in users(:librarian1)
    get :edit, :id => 1, :upload => true
    assert_response :success
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_resource
    put :update, :id => 1, :resource => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_resource
    sign_in users(:user1)
    put :update, :id => 1, :resource => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_resource_without_title
    sign_in users(:librarian1)
    put :update, :id => 1, :resource => { :original_title => nil }
    assert_response :success
  end
  
  def test_librarian_should_update_resource
    sign_in users(:librarian1)
    put :update, :id => 1, :resource => { }
    assert_redirected_to resource_url(assigns(:resource))
    assigns(:resource).remove_from_index!
  end
  
  def test_admin_should_update_resource
    sign_in users(:admin)
    put :update, :id => 1, :resource => { }
    assert_redirected_to resource_url(assigns(:resource))
    assigns(:resource).remove_from_index!
  end
  
  def test_guest_should_not_destroy_resource
    old_count = Resource.count
    delete :destroy, :id => 1
    assert_equal old_count, Resource.count
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_resource
    sign_in users(:user1)
    old_count = Resource.count
    delete :destroy, :id => 1
    assert_equal old_count, Resource.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_resource
    sign_in users(:librarian1)
    old_count = Resource.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Resource.count
    
    assert_redirected_to resources_url
  end

  def test_admin_should_destroy_resource
    sign_in users(:admin)
    old_count = Resource.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Resource.count
    
    assert_redirected_to resources_url
  end
end
