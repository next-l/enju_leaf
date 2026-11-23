require 'rails_helper'

describe Manifestation do
  fixtures :manifestations, :agents, :creates, :produces, :create_types, :produce_types

  before do
    # Create/Produce#reindex and the touch callbacks they trigger talk to
    # Solr, which is not available in this spec.
    allow_any_instance_of(Agent).to receive(:index)
    allow_any_instance_of(Manifestation).to receive(:index)
    allow(Sunspot).to receive(:commit)
  end

  describe "#set_agent_role_type" do
    it "sets the create_type for creators" do
      manifestation = manifestations(:manifestation_00001)

      manifestation.set_agent_role_type([ { full_name: "Administrator||editor" } ])

      expect(creates(:create_00001).reload.create_type).to eq create_types(:editor)
    end

    it "sets the produce_type for publishers" do
      manifestation = manifestations(:manifestation_00001)

      manifestation.set_agent_role_type([ { full_name: "Administrator||seller" } ], scope: :publisher)

      expect(produces(:produce_00001).reload.produce_type).to eq produce_types(:seller)
    end

    it "handles multiple agent lists without changing the result" do
      manifestation = manifestations(:manifestation_00001)

      manifestation.set_agent_role_type([
        { full_name: "Administrator||editor" },
        { full_name: "Librarian1||translator" }
      ])

      expect(creates(:create_00001).reload.create_type).to eq create_types(:editor)
      expect(creates(:create_00003).reload.create_type).to eq create_types(:translator)
    end

    it "does nothing when the agent cannot be found" do
      manifestation = manifestations(:manifestation_00001)

      expect {
        manifestation.set_agent_role_type([ { full_name: "Nonexistent Agent||editor" } ])
      }.not_to raise_error
    end

    it "raises an error for unsupported scopes" do
      manifestation = manifestations(:manifestation_00001)

      expect {
        manifestation.set_agent_role_type([ { full_name: "Administrator||editor" } ], scope: :unknown)
      }.to raise_error("unknown is not supported!")
    end
  end
end
