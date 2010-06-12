require File.dirname(__FILE__) + '/../test_helper'

class BasketTest < ActiveSupport::TestCase
  fixtures :baskets, :users

  def test_should_not_create_basket_when_user_is_not_active
    basket = Basket.create(:user => users(:user3))
    assert_nil basket.id
  end
end
