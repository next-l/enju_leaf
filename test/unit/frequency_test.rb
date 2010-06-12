require File.dirname(__FILE__) + '/../test_helper'

class FrequencyTest < ActiveSupport::TestCase
  fixtures :frequencies

  # Replace this with your real tests.
  def test_should_have_display_name
    assert_not_nil frequencies(:frequency_00001).display_name
  end
end
