require 'test_helper'

class EventsControllerTest < ActionController::TestCase
    fixtures :events, :event_categories, :libraries, :patrons, :users

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

  def test_librarian_should_get_new_with_date
    sign_in users(:librarian1)
    get :new, :date => '2010/09/01'
    assert_response :success
  end
  
  def test_librarian_should_get_new_with_invalid_date
    sign_in users(:librarian1)
    get :new, :date => '2010/13/01'
    assert_response :success
    assert_equal flash[:notice], I18n.t('page.invalid_date')
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
end
