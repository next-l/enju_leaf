# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "page/opensearch" do
  fixtures :all

  before(:each) do
    assign(:library_group, LibraryGroup.site_config)
    view.stub(:current_user).and_return(User.find('enjuadmin'))
  end

  it "renders the XML template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Library Catalog/)
  end
end
