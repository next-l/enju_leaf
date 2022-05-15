require 'rails_helper'

describe Resourcesync do
  fixtures :all

  it "generate_capabilitylist" do
    expect(Resourcesync.new.generate_capabilitylist).to be_truthy
  end

  it "generate_resourcelist_index" do
    expect(Resourcesync.new.generate_resourcelist_index(Manifestation.all)).to be_truthy
  end

  it "generate_resourcelist" do
    expect(Resourcesync.new.generate_resourcelist(Manifestation.all)).to be_truthy
  end

  it "generate_changelist_index" do
    expect(Resourcesync.new.generate_changelist_index(Manifestation.all)).to be_truthy
  end

  it "generate_changelist" do
    expect(Resourcesync.new.generate_changelist(Manifestation.all)).to be_truthy
  end
end
