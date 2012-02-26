require 'spec_helper'

describe "library_groups/show" do
  before(:each) do
    @library_group = LibraryGroup.site_config
  end

  it "renders attributes in <p>" do
    render
  end
end
