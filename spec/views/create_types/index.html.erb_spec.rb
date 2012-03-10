# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "create_types/index" do
  before(:each) do
    assign(:create_types, [
      stub_model(CreateType,
        :name => "Name",
        :display_name => "ja: テキスト",
        :note => "MyText",
        :position => 1
      ),
      stub_model(CreateType,
        :name => "Name",
        :display_name => "ja: テキスト",
        :note => "MyText",
        :position => 1
      )
    ])
  end

  it "renders a list of create_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "テキスト".to_s, :count => 2
  end
end
