require 'rails_helper'

RSpec.describe OaiController, type: :controller do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:manifestation)
  end

  describe 'GET index', solr: true do
    before do
      50.times do
        FactoryBot.create(:manifestation)
      end
      Manifestation.reindex
    end

    describe 'When not logged in' do
      it 'assigns all manifestations as @manifestations in oai format without verb' do
        get :provider, params: { format: 'xml' }
        assigns(:manifestations).should_not be_nil
        response.should render_template('oai/provider')
      end

      it 'should not assign all manifestations as @manifestations in oai format with ListRecords without metadataPrefix' do
        get :provider, params: { format: 'xml', verb: 'ListRecords' }
        assigns(:manifestations).should_not be_nil
        response.should render_template('oai/provider')
      end

      it 'assigns all manifestations as @manifestations in oai format with ListRecords for junii2 metadata' do
        get :provider, params: { format: 'xml', verb: 'ListRecords', metadataPrefix: 'junii2' }
        assigns(:manifestations).should_not be_nil
        response.should render_template('oai/list_records')
      end

      it 'should not assign all manifestations as @manifestations in oai format with ListIdentifiers without metadataPrefix' do
        get :provider, params: { format: 'xml', verb: 'ListIdentifiers' }
        assigns(:manifestations).should_not be_nil
        response.should render_template('oai/provider')
      end

      it 'assigns all manifestations as @manifestations in oai format with ListIdentifiers for junii2 metadata' do
        get :provider, params: { format: 'xml', verb: 'ListIdentifiers', metadataPrefix: 'junii2' }
        assigns(:manifestations).should_not be_nil
        response.should render_template('oai/list_identifiers')
      end

      it 'assigns all manifestations as @manifestations in oai format with GetRecord without identifier' do
        get :provider, params: { format: 'xml', verb: 'GetRecord' }
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        response.should render_template('oai/provider')
      end

      it 'should not assign all manifestations as @manifestations in oai format with GetRecord with identifier without metadataPrefix' do
        manifestation = Manifestation.first
        get :provider, params: { format: 'xml', verb: 'GetRecord', identifier: "oai:localhost:manifestations-#{manifestation.id}" }
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('oai/provider')
      end

      it 'assigns all manifestations as @manifestations in oai format with GetRecord with identifier for junii2 metadata' do
        manifestation = Manifestation.first
        get :provider, params: { format: 'xml', verb: 'GetRecord', identifier: "oai:localhost:manifestations-#{manifestation.id}", metadataPrefix: 'junii2' }
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('oai/get_record')
      end

      it "should return only public identifiers for oai_dc metadata" do
        get :provider, params: { format: 'xml', verb: 'ListIdentifiers', metadataPrefix: 'oai_dc' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end

      it "should return only public identifiers for junii2 metadata" do
        get :provider, params: { format: 'xml', verb: 'ListIdentifiers', metadataPrefix: 'junii2' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end

      it "should return only public records for oai_dc metadata" do
        get :provider, params: { format: 'xml', verb: 'ListRecords', metadataPrefix: 'oai_dc' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end

      it "should return only public records for junii2 metadata" do
        get :provider, params: { format: 'xml', verb: 'ListRecords', metadataPrefix: 'junii2' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end
    end
  end
end
