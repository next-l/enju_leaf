require 'spec_helper'

describe "exchange_rates/edit" do
  before(:each) do
    @exchange_rate = assign(:exchange_rate, stub_model(ExchangeRate,
      :id => 1,
      :currency_id => 1,
      :rate => "9.99"
    ))
  end

  it "renders the edit exchange_rate form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", exchange_rate_path(@exchange_rate), "post" do
      assert_select "input#exchange_rate_id[name=?]", "exchange_rate[id]"
      assert_select "input#exchange_rate_currency_id[name=?]", "exchange_rate[currency_id]"
      assert_select "input#exchange_rate_rate[name=?]", "exchange_rate[rate]"
    end
  end
end
