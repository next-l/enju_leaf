require 'rails_helper'

describe OaiController do
  fixtures :all

  before(:each) do
    manifestations(:manifestation_00001).attachment.attach(
      io: File.open(Rails.root.join('README.md')),
      filename: 'README.md'
    )
  end

  describe "GET identify" do
    it "should get identify" do
      get :index, params: { verb: "Identify" }
      expect(response).to be_successful
    end

    it "should get list_records" do
      get :index, params: { verb: "ListRecords", "metadataPrefix": "jpcoar" }
      expect(response).to be_successful
    end
  end
end
