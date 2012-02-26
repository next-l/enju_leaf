require 'spec_helper'

describe "exemplifies/edit" do
  before(:each) do
    @exemplify = assign(:exemplify, stub_model(Exemplify,
      :manifestation_id => 1,
      :item_id => 1
    ))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders the edit exemplify form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => exemplifies_path(@exemplify), :method => "post" do
      assert_select "input#exemplify_manifestation_id", :name => "exemplify[manifestation_id]"
    end
  end
end
