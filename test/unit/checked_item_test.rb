require 'test_helper'

class CheckedItemTest < ActiveSupport::TestCase
  fixtures :users, :patrons, :patron_types, :languages, :countries,
    :checked_items, :items, :manifestations,
    :carrier_types, :content_types, :shelves

  test "should respond to available_for_checkout?" do
    assert !checked_items(:checked_item_00001).available_for_checkout?
  end
end
