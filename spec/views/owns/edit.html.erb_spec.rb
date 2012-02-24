require 'spec_helper'

describe "owns/edit" do
  before(:each) do
    @own = assign(:own, stub_model(Own,
      :item_id => 1,
      :patron_id => 1
    ))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders the edit own form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => owns_path(@own), :method => "post" do
      assert_select "input#own_item_id", :name => "own[item_id]"
    end
  end
end
