# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "produce_types/index.html.erb" do
  before(:each) do
    assign(:produce_types, [
      stub_model(ProduceType,
        :name => "Name",
        :display_name => "ja: テキスト",
        :note => "MyText",
        :position => 1
      ),
      stub_model(ProduceType,
        :name => "Name",
        :display_name => "ja: テキスト",
        :note => "MyText",
        :position => 1
      )
    ])
  end

  it "renders a list of produce_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "テキスト".to_s, :count => 2
  end
end
