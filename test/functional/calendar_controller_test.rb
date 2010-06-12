require 'test_helper'

class CalendarControllerTest < ActionController::TestCase
    fixtures :events, :event_categories

  def test_guest_should_get_index
    get :index, :year => 2010, :month => 3
    assert_response :success
    assert assigns(:event_strips)
  end

end
