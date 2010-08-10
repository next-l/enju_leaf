require 'test_helper'

class LibraryTest < ActiveSupport::TestCase
  fixtures :libraries

  def test_library_should_create_default_shelf
    patron = Patron.create!(:full_name => 'test')
    library = Library.create!(:name => 'test', :short_display_name => 'test')
    assert library.shelves.first
    assert_equal library.shelves.first.name, 'test_default'
  end
end
