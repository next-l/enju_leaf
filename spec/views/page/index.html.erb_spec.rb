# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "page/index" do
  fixtures :all

  before(:each) do
    assign(:tags, Tag.all)
    view.stub(:current_user).and_return(User.find('enjuadmin'))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Catalog search/)
  end
end
