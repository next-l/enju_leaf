require 'rails_helper'

describe "checkouts/index" do
  fixtures :all

  before(:each) do
    assign(:checkouts, Checkout.page(1))
    assign(:checkouts_facet, [])
    view.stub(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders a list of checkouts" do
    allow(view).to receive(:policy).and_return double(update?: true, destroy?: true)
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr:nth-child(2)>td:nth-child(2)", /00001/
  end
end
