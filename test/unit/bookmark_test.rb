require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  fixtures :bookmarks,
    :users, :patrons, :patron_types, :languages, :countries,
    :checked_items, :items, :resources,
    :carrier_types, :content_types,
    :shelves, :circulation_statuses, :libraries, :library_groups,
    :users, :user_groups, :lending_policies

  def test_bookmark_sheved
    assert bookmarks(:bookmark_00001).shelved?
  end

  #def test_bookmark_create_bookmark_item
  #  old_count = Item.count
  #  bookmark = users(:user1).bookmarks.create(:manifestation_id => 5, :title => 'test')
  #  assert_not_nil bookmarks(:bookmark_00001).manifestation.items
  #  assert_equal old_count + 1, Item.count
  #end

  def test_bookmark_create_bookmark_with_url
    old_manifestation_count = Resource.count
    old_item_count = Item.count
    assert_difference('Bookmark.count') do
      bookmark = users(:user1).bookmarks.create(:url => 'http://www.example.com/', :title => 'test')
    end
    assert_equal old_manifestation_count + 1, Resource.count
    assert_equal old_item_count + 1, Item.count
  end

  def test_bookmark_create_bookmark_with_local_resource_url
    old_manifestation_count = Resource.count
    old_item_count = Item.count
    assert_difference('Bookmark.count') do
      bookmark = users(:user1).bookmarks.create(:url => "#{LibraryGroup.url}resources/1", :title => 'test')
    end
    assert_equal old_manifestation_count, Resource.count
    assert_equal old_item_count, Item.count
  end

  def test_bookmark_create_bookmark_without_local_resource_url
    old_manifestation_count = Resource.count
    old_item_count = Item.count
    assert_no_difference('Bookmark.count') do
      bookmark = users(:user1).bookmarks.create(:url => "#{LibraryGroup.url}libraries/1", :title => 'test')
    end
    assert_equal old_manifestation_count, Resource.count
    assert_equal old_item_count, Item.count
  end

end
