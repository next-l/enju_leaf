require 'spec_helper'

describe "accepts/index" do
  before(:each) do
    assign(:accepts, [
      stub_model(Accept,
        :item_id => 1,
        :created_at => Time.zone.now
      ),
      stub_model(Accept,
        :item_id => 1,
        :created_at => Time.zone.now
      )
    ].paginate(:page => 1))
    basket = FactoryGirl.create(:basket)
    assign(:basket, basket)
    assign(:accept, basket.accepts.new)
  end

  it "renders a list of accepts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td"
  end
end
