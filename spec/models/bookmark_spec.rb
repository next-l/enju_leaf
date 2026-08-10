# -*- encoding: utf-8 -*-
require 'rails_helper'

describe Bookmark do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it "should be shelved" do
    bookmarks(:bookmark_00001).shelved?.should be_truthy
  end

  it "should create bookmark with url" do
    old_manifestation_count = Manifestation.count
    old_item_count = Item.count
    lambda{
      bookmark = FactoryBot.create(:user).bookmarks.create(url: 'http://www.example.com/', title: 'test')
    }.should change(Bookmark, :count)
    Manifestation.count.should eq old_manifestation_count + 1
    Item.count.should eq old_item_count + 1
  end

  it "should create bookmark with local resource url" do
    old_manifestation_count = Manifestation.count
    old_item_count = Item.count
    lambda{
      bookmark = FactoryBot.create(:user).bookmarks.create(url: "#{LibraryGroup.site_config.url}manifestations/1", title: 'test')
    }.should change(Bookmark, :count)
    assert_equal old_manifestation_count, Manifestation.count
    assert_equal old_item_count, Item.count
  end

  it "should not create bookmark with local resource url" do
    old_manifestation_count = Manifestation.count
    old_item_count = Item.count
    lambda{
      bookmark = FactoryBot.create(:user).bookmarks.create(url: "#{LibraryGroup.site_config.url}libraries/1", title: 'test')
    }.should_not change(Bookmark, :count)
    assert_equal old_manifestation_count, Manifestation.count
    assert_equal old_item_count, Item.count
  end
end

# ## Schema Information
#
# Table name: `bookmarks`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `bigint`           | `not null, primary key`
# **`note`**              | `text`             |
# **`shared`**            | `boolean`          | `default(FALSE), not null`
# **`title`**             | `text`             | `not null`
# **`url`**               | `string`           | `not null`
# **`created_at`**        | `datetime`         | `not null`
# **`updated_at`**        | `datetime`         | `not null`
# **`manifestation_id`**  | `bigint`           |
# **`user_id`**           | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_bookmarks_on_manifestation_id`:
#     * **`manifestation_id`**
# * `index_bookmarks_on_url`:
#     * **`url`**
# * `index_bookmarks_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
