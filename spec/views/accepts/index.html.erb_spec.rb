require 'rails_helper'

describe "accepts/index" do
  fixtures :all

  before(:each) do
    assign(:accepts, Accept.page(1))
    basket = FactoryBot.create(:basket)
    assign(:basket, basket)
    assign(:accept, basket.accepts.new)
  end

  it "renders a list of accepts" do
    allow(view).to receive(:policy).and_return double(create?: true, destroy?: true)
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td"
  end
end
