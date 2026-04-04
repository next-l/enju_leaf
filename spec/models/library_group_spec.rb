require 'rails_helper'

describe LibraryGroup do
  fixtures :library_groups, :users

  before(:each) do
    @library_group = LibraryGroup.find(1)
  end

  it "should get library_group_config" do
    LibraryGroup.site_config.should be_truthy
  end

  it "should set 1000 as max_number_of_results" do
    expect(LibraryGroup.site_config.max_number_of_results).to eq 1000
  end

  it "should allow access from allowed networks" do
    @library_group.my_networks = "127.0.0.1"
    @library_group.network_access_allowed?("192.168.0.1").should be_falsy
  end

  it "should accept 0 as max_number_of_results" do
    @library_group.update(max_number_of_results: 0).should be_truthy
  end

  it "should serialize settings" do
    expect(@library_group.book_jacket_unknown_resource).to eq 'unknown.png'
  end
end
