require File.dirname(__FILE__) + '/../test_helper'

class ExemplifyTest < ActiveSupport::TestCase
  def test_manifestation_should_create_lending_policy
    assert exemplifies(:exemplify_00001).create_lending_policy
  end
end
