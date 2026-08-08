require 'rails_helper'

describe OaiController do
  fixtures :all

  before(:each) do
    manifestatons(:manifestation_00001).attach(
      io: File.open(Rails.root.join('README.md')),
      filename: 'README.md'
    )
  end

  describe "GET identify" do
    it "should get identify" do
      get oai_path(verb: "Identify")
      expect(response).to be_successful
    end

    it "should get list_records" do
      get oai_path(verb: "ListRecords", metadataPrefix: "jpcoar_2.0")
      expect(response).to be_successful
    end
  end
end
