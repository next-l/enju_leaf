require 'spec_helper'

describe "exemplifies/new" do
  before(:each) do
    assign(:exemplify, stub_model(Exemplify,
      :manifestation_id => 1,
      :item_id => 1
    ).as_new_record)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders new exemplify form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => exemplifies_path, :method => "post" do
      assert_select "input#exemplify_manifestation_id", :name => "exemplify[manifestation_id]"
    end
  end
end
