require 'test_helper'

class InterLibraryLoansControllerTest < ActionController::TestCase
    fixtures :inter_library_loans, :libraries, :users

  def test_guest_should_not_get_index
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_get_index
    sign_in users(:user1)
    get :index
    assert_response :forbidden
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:inter_library_loans)
  end

  def test_librarian_should_get_index_feed
    sign_in users(:librarian1)
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:inter_library_loans)
  end

  def test_librarian_should_get_index_with_item_id
    sign_in users(:librarian1)
    get :index, :item_id => 1
    assert_response :success
    assert assigns(:inter_library_loans)
    assert assigns(:item)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:inter_library_loans)
  end

  def test_guest_should_not_get_new
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new, :item_id => 3
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new, :item_id => 3
    assert_response :success
  end
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new, :item_id => 3
    assert_response :success
  end
  
  def test_guest_should_not_create_inter_library_loan
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => { }
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_create_inter_library_loan_without_item_id
    sign_in users(:admin)
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => {:borrowing_library_id => 1}
    assert_equal old_count, InterLibraryLoan.count
    
    assert_response :success
  end

  def test_everyone_should_not_create_inter_library_loan_without_borrowing_library_id
    sign_in users(:admin)
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => {:item_identifier => '00001'}
    assert_equal old_count, InterLibraryLoan.count
    
    assert_response :success
  end

  def test_user_should_not_create_inter_library_loan
    sign_in users(:user1)
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => {:item_identifier => '00005', :borrowing_library_id => 2}
    assert_equal old_count, InterLibraryLoan.count
    
    assert_response :forbidden
  end

  def test_librarian_should_create_inter_library_loan
    sign_in users(:librarian1)
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => {:item_identifier => '00005', :borrowing_library_id => 2}
    assert_equal old_count+1, InterLibraryLoan.count
    
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'Recalled', assigns(:inter_library_loan).item.circulation_status.name
    assert_equal 'requested', assigns(:inter_library_loan).state
  end

  def test_admin_should_create_inter_library_loan
    sign_in users(:admin)
    old_count = InterLibraryLoan.count
    post :create, :inter_library_loan => {:item_identifier => '00005', :borrowing_library_id => 2}
    assert_equal old_count+1, InterLibraryLoan.count
    
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
  end

  def test_guest_should_not_show_inter_library_loan
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_show_missing_inter_library_loan
    sign_in users(:admin)
    get :show, :id => 100, :user_id => users(:user1).username
    assert_response :missing
  end

  def test_user_should_not_show_inter_library_loan
    sign_in users(:user1)
    get :show, :id => 3
    assert_response :forbidden
  end

  def test_librarian_should_show_inter_library_loan
    sign_in users(:librarian1)
    get :show, :id => 3
    assert_response :success
  end

  def test_admin_should_show_inter_library_loan
    sign_in users(:admin)
    get :show, :id => 3
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 3
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_get_missing_edit
    sign_in users(:admin)
    get :edit, :id => 100
    assert_response :missing
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id =>3
    assert_response :forbidden
  end
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_guest_should_not_update_inter_library_loan
    put :update, :id => 1, :inter_library_loan => { }
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_everyone_should_not_update_inter_library_loan_without_borrowing_library_id
    sign_in users(:admin)
    put :update, :id => 1, :inter_library_loan => {:borrowing_library_id => nil}
    assert_response :success
  end
  
  def test_everyone_should_not_update_inter_library_loan_without_item_id
    sign_in users(:admin)
    put :update, :id => 1, :inter_library_loan => {:item_id => nil}
    assert_response :success
  end
  
  def test_everyone_should_not_update_missing_inter_library_loan
    sign_in users(:admin)
    put :update, :id => 100, :inter_library_loan => { }
    assert_response :missing
  end
  
  def test_user_should_not_update_inter_library_loan
    sign_in users(:user1)
    put :update, :id => 3, :inter_library_loan => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_update_requested_inter_library_loan
    sign_in users(:librarian1)
    put :update, :id => 1, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'shipped', assigns(:inter_library_loan).state
  end

  def test_librarian_should_update_shipped_inter_library_loan
    sign_in users(:librarian1)
    put :update, :id => 2, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'received', assigns(:inter_library_loan).state
  end

  def test_librarian_should_update_received_inter_library_loan
    sign_in users(:librarian1)
    put :update, :id => 3, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'return_shipped', assigns(:inter_library_loan).state
  end

  def test_librarian_should_update_return_shipped_inter_library_loan
    sign_in users(:librarian1)
    put :update, :id => 4, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'return_received', assigns(:inter_library_loan).state
  end

  def test_item_status_should_be_in_transit_when_shipped
    sign_in users(:librarian1)
    put :update, :id => 6, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
    assert_equal 'In Transit Between Library Locations', assigns(:inter_library_loan).item.circulation_status.name
    assert_equal 'shipped', assigns(:inter_library_loan).state
  end

  def test_admin_should_update_inter_library_loan
    sign_in users(:admin)
    put :update, :id => 3, :inter_library_loan => { }
    assert_redirected_to inter_library_loan_url(assigns(:inter_library_loan))
  end

  def test_guest_should_not_destroy_inter_library_loan
    old_count = InterLibraryLoan.count
    delete :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  def test_everyone_should_not_destroy_missing_inter_library_loan
    sign_in users(:admin)
    old_count = InterLibraryLoan.count
    delete :destroy, :id => 100, :user_id => users(:user1).username
    assert_equal old_count, InterLibraryLoan.count
    
    assert_response :missing
  end

  def test_user_should_not_destroy_inter_library_loan
    sign_in users(:user1)
    old_count = InterLibraryLoan.count
    delete :destroy, :id => 3
    assert_equal old_count, InterLibraryLoan.count
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_inter_library_loan
    sign_in users(:librarian1)
    old_count = InterLibraryLoan.count
    delete :destroy, :id => 3
    assert_equal old_count-1, InterLibraryLoan.count
    
    assert_redirected_to inter_library_loans_url
  end

  def test_librarian_should_destroy_inter_library_loan
    sign_in users(:admin)
    old_count = InterLibraryLoan.count
    delete :destroy, :id => 3
    assert_equal old_count-1, InterLibraryLoan.count
    
    assert_redirected_to inter_library_loans_url
  end
end
