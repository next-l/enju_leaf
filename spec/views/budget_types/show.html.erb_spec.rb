require 'rails_helper'

describe "budget_types/show" do
  before(:each) do
    @budget_type = assign(:budget_type, BudgetType.create(
      name: "Name",
      display_name: "MyText",
      note: "MyText",
      position: 1
    ))
  end

  it "renders attributes in <p>" do
    allow(view).to receive(:policy).and_return double(update?: true)
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
  end
end
