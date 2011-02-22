require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  fixtures :items, :circulation_statuses, :checkouts, :shelves, :manifestations, :carrier_types,
    :creates, :realizes, :produces, :owns,
    :languages, :libraries, :users, :patrons, :user_groups, :reserves,
    :content_types, :form_of_works, :library_groups, :bookstores, :patron_types,
    :message_templates, :message_requests, :barcodes, :request_status_types

  # Replace this with your real tests.
  def test_item_is_rent
    assert items(:item_00001).rent?
  end

  def test_item_is_not_rent
    assert_equal false, items(:item_00010).rent?
  end

  def test_item_should_be_checked_out
    assert items(:item_00010).checkout!(users(:admin))
    assert_equal 'On Loan', items(:item_00010).circulation_status.name
  end

  def test_item_should_be_checked_in
    assert items(:item_00001).checkin!
    assert_equal 'Available On Shelf', items(:item_00001).circulation_status.name
  end

  def test_item_should_be_retained
    old_count = MessageRequest.count
    assert items(:item_00013).retain(users(:librarian1))
    assert_equal old_count + 1, MessageRequest.count
  end

  def test_claimed_item_should_not_be_checked_out
    assert_equal false, items(:item_00012).available_for_checkout?
  end

  def test_should_have_library_url
    assert_equal "#{LibraryGroup.site_config.url}libraries/web", items(:item_00001).library_url
  end

end
