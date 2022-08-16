require "rails_helper.rb"

describe "manifestations/show.ttl.ruby" do
  before(:each) do
    @manifestation = assign(:manifestation, FactoryBot.create(:manifestation))
    @library_group = LibraryGroup.first
  end

  it "should export TTL format" do
    render
  end
end

