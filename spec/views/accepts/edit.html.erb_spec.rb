require 'rails_helper'

describe "accepts/edit" do
  before(:each) do
    @accept = assign(:accept, FactoryBot.create(:accept))
  end

  it "renders the edit accept form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: accepts_path(@accept), method: "post" do
      assert_select "input#accept_item_id", name: "accept[item_id]"
    end
  end
end
