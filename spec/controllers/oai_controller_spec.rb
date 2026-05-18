require 'rails_helper'

RSpec.describe OaiController, type: :controller do
  fixtures :all

  describe 'GET index', solr: true do
    describe 'When not logged in' do
      it 'assigns all manifestations as @manifestations in oai format without verb' do
        get :index, params: { metadataPrefix: 'oai_dc' }
        assigns(:manifestations).should_not be_nil
      end

      it 'should not assign all manifestations as @manifestations in oai format with ListRecords without metadataPrefix' do
        get :index, params: { verb: 'ListRecords' }
        assigns(:manifestations).should_not be_nil
      end

      it 'should not assign all manifestations as @manifestations in oai format with ListIdentifiers without metadataPrefix' do
        get :index, params: { verb: 'ListIdentifiers' }
        assigns(:manifestations).should_not be_nil
      end

      it 'assigns all manifestations as @manifestations in oai format with GetRecord without identifier' do
        get :index, params: { verb: 'GetRecord', metadataFormat: 'oai_dc' }
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        response.should render_template('oai/provider')
      end

      it 'should not assign all manifestations as @manifestations in oai format with GetRecord with identifier without metadataPrefix' do
        manifestation = Manifestation.first
        get :index, params: { verb: 'GetRecord', identifier: "oai:localhost:manifestations:#{manifestation.id}", metadataFormat: 'oai_dc' }
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
      end

      it "should return only public identifiers for jpcoar_2.0 metadata" do
        get :index, params: { verb: 'ListIdentifiers', metadataPrefix: 'jpcoar_2.0' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end

      it "should return only public records for jpcoar_2.0 metadata" do
        get :index, params: { verb: 'ListRecords', metadataPrefix: 'jpcoar_2.0' }
        expect(assigns(:manifestations).map(&:id).include?(11)).to be_falsy
        expect(assigns(:manifestations).map(&:id).include?(24)).to be_falsy
      end
    end
  end
end
