require 'rails_helper'

describe "accepts/new" do
  fixtures :all

  before(:each) do
    assign(:accept, Accept.new(
      item_id: 1
    ))
    assign(:basket, FactoryBot.create(:basket))
    assign(:accepts, Accept.page(1))
  end

  it "renders new accept form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: accepts_path, method: "post" do
      assert_select "input#accept_item_identifier", name: "accept[item_identifier]"
    end
  end
end
