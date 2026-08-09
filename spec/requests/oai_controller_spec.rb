require 'rails_helper'

RSpec.describe "OaiController", type: :request do
  describe "GET /oai" do
    fixtures :all
    before(:each) do
      @manifestation = manifestations(:manifestation_00001)
    end

    it "should get Identify" do
      get oai_path(verb: 'Identify')
      expect(response).to be_successful
    end

    it "should get ListIdentifiers" do
      get oai_path(verb: 'Identify')
      expect(response).to be_successful
    end

    describe 'oai_dc' do
      before(:each) do
        @metadata_format = 'oai_dc'
      end

      it "should get ListRecord" do
        get oai_path(verb: 'ListRecords', metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end

      it "should get GetRecord" do
        get oai_path(verb: 'GetRecord', identifier: "oai:localhost:manifestations:#{@manifestation.id}", metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end
    end

    describe 'jpcoar_2.0' do
      before(:each) do
        @metadata_format = 'jpcoar_2.0'
      end

      it "should get ListRecords" do
        get oai_path(verb: 'ListRecords', metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end

      it "should get GetRecord" do
        get oai_path(verb: 'GetRecord', identifier: "oai:localhost:manifestations:#{@manifestation.id}", metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end
    end

    describe 'dcndl' do
      before(:each) do
        @metadata_format = 'dcndl'
      end

      it "should get ListRecords" do
        get oai_path(verb: 'ListRecords', metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end

      it "should get GetRecord" do
        get oai_path(verb: 'GetRecord', identifier: "oai:localhost:manifestations:#{@manifestation.id}", metadataPrefix: @metadata_format)
        expect(response).to be_successful
      end
    end
  end
end
