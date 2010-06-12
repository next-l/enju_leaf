require File.dirname(__FILE__) + '/../test_helper'

class LibraryGroupTest < ActiveSupport::TestCase
  fixtures :library_groups

  def test_library_group_config
    assert LibraryGroup.site_config
  end

end
