require 'test_helper'

class EventsControllerTest < ActionController::TestCase
    fixtures :events, :event_categories, :libraries, :patrons, :users

  def test_guest_should_get_index
    get :index
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_get_index_csv
    get :index, :format => 'csv'
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_get_index_rss
    get :index, :format => 'rss'
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_get_index_ics
    get :index, :format => 'ics'
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_get_index_with_library_id
    get :index, :library_id => 'kamata'
    assert_response :success
    assert assigns(:library)
    assert assigns(:events)
  end

  def test_guest_should_get_upcoming_event_index
    get :index, :mode => 'upcoming'
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_get_past_event_index
    get :index, :mode => 'past'
    assert_response :success
    assert assigns(:events)
  end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:events)
  end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:events)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:events)
  end

  def test_guest_should_not_get_new
    get :new
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_new
    sign_in users(:user1)
    get :new
    assert_response :forbidden
  end
  
  def test_librarian_should_get_new
    sign_in users(:librarian1)
    get :new
    assert_response :success
  end
  
  def test_admin_should_get_new
    sign_in users(:admin)
    get :new
    assert_response :success
  end
  
  def test_guest_should_not_create_event
    assert_no_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_create_event
    assert_no_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_librarian_should_create_event_without_library_id
    sign_in users(:librarian1)
    assert_difference('Event.count') do
      post :create, :event => { :name => 'test', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end

  def test_librarian_should_create_event_without_category_id
    sign_in users(:librarian1)
    assert_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end

  def test_librarian_should_not_create_event_with_invalid_dates
    sign_in users(:librarian1)
    assert_no_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-08', :end_at => '2008-02-05' }
    end
    
    assert_response :success
    assert assigns(:event).errors['start_at']
  end

  def test_librarian_should_create_event
    sign_in users(:librarian1)
    assert_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end

  def test_admin_should_create_event
    sign_in users(:admin)
    assert_difference('Event.count') do
      post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
    end
    
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end

  def test_guest_should_show_event
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_show_event
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_event
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_admin_should_show_event
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
  
  def test_librarian_should_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_admin_should_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_guest_should_not_update_event
    put :update, :id => 1, :event => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_event
    sign_in users(:user1)
    put :update, :id => 1, :event => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_event_without_library_id
    sign_in users(:librarian1)
    put :update, :id => 1, :event => {:library_id => nil}
    assert_response :success
  end
  
  def test_librarian_should_update_event_without_event_category_id
    sign_in users(:librarian1)
    put :update, :id => 1, :event => {:event_category_id => nil}
    assert_response :success
    assigns(:event).remove_from_index!
  end
  
  def test_librarian_should_not_update_event_with_invalid_date
    sign_in users(:librarian1)
    put :update, :id => 1, :event => {:start_at => '2008-02-08', :end_at => '2008-02-05' }
    assert_response :success
    assert assigns(:event).errors['start_at']
  end
  
  def test_librarian_should_update_event
    sign_in users(:librarian1)
    put :update, :id => 1, :event => { }
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end
  
  def test_admin_should_update_event
    sign_in users(:admin)
    put :update, :id => 1, :event => { }
    assert_redirected_to event_url(assigns(:event))
    assigns(:event).remove_from_index!
  end
  
  def test_guest_should_not_destroy_event
    assert_no_difference('Event.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_event
    sign_in users(:user1)
    assert_no_difference('Event.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_destroy_event
    sign_in users(:librarian1)
    assert_difference('Event.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to events_url
  end

  def test_admin_should_destroy_event
    sign_in users(:admin)
    assert_difference('Event.count', -1) do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to events_url
  end
end
