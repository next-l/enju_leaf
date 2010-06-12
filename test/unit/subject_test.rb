require File.dirname(__FILE__) + '/../test_helper'

class SubjectTest < ActiveSupport::TestCase
  fixtures :subjects

  # Replace this with your real tests.
  def test_should_get_term
    assert_not_nil subjects(:subject_00001).term
  end
end
