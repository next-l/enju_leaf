require 'rails_helper'

describe "checked_items/new" do
  fixtures :all

  it "renders new checkout form" do
    profile = FactoryBot.create(:profile, user_number: "foo")
    user = FactoryBot.create(:user, profile: profile, username: "bar")
    basket = FactoryBot.create(:basket, user: user)
    assign(:basket, basket)
    assign(:checked_item, CheckedItem.new)
    assign(:checked_items, basket.checked_items)
    render
    expect(rendered).to match /bar/
    expect(rendered).to match /foo/
  end
end
