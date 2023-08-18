require 'rails_helper'

describe "budget_types/index" do
  before(:each) do
    assign(:budget_types, BudgetType.all)
  end

  it "renders a list of budget_types" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true, destroy?: true)
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: "Public fund".to_s, count: 2
  end
end
