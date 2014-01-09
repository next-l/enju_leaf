require 'spec_helper'

describe "exchange_rates/new" do
  before(:each) do
    assign(:exchange_rate, stub_model(ExchangeRate,
      :id => 1,
      :currency_id => 1,
      :rate => "9.99"
    ).as_new_record)
  end

  it "renders new exchange_rate form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", exchange_rates_path, "post" do
      assert_select "input#exchange_rate_id[name=?]", "exchange_rate[id]"
      assert_select "input#exchange_rate_currency_id[name=?]", "exchange_rate[currency_id]"
      assert_select "input#exchange_rate_rate[name=?]", "exchange_rate[rate]"
    end
  end
end
