require 'spec_helper'

describe "creates/new.html.erb" do
  fixtures :create_types

  before(:each) do
    assign(:create, stub_model(Create,
      :work_id => 1,
      :patron_id => 1
    ).as_new_record)
    @create_types = CreateType.all
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders new create form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => creates_path, :method => "post" do
      assert_select "input#create_work_id", :name => "create[work_id]"
    end
  end
end
