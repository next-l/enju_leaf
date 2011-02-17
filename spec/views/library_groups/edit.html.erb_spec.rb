require 'spec_helper'

describe "library_groups/edit.html.erb" do
  before(:each) do
    @library_group = LibraryGroup.site_config
    @countries = Country.all
  end

  it "renders attributes in <p>" do
    render
  end
end
