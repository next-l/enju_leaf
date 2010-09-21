require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
    fixtures :events, :event_categories

  def test_guest_should_get_index
    get :index, :year => 2010, :month => 3
    assert_response :success
    assert assigns(:event_strips)
  end

  def test_guest_should_get_new_event
    get :show, :year => 2010, :month => 3, :day => 1
    assert_response :redirect
    assert_redirected_to new_event_path(:date => '2010/03/01')
  end

  def test_guest_should_get_existing_event
    get :show, :year => 2008, :month => 1, :day => 13
    assert_response :redirect
    assert_redirected_to events_path(:date => '2008/01/13')
  end

end
