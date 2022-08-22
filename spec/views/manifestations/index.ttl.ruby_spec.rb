require "rails_helper.rb"

describe "manifestations/index.ttl.ruby" do
  before(:each) do
    manifestation = FactoryBot.create(:manifestation)
    @manifestations = assign(:manifestations, [manifestation])
    @library_group = LibraryGroup.first
  end

  it "should export TTL format" do
    render
  end
end

