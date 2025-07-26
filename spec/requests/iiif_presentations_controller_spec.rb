require 'rails_helper'

RSpec.describe "IiifPresentationsController", type: :request do
  describe "GET /show" do
    fixtures :all
    before(:each) do
      @manifestation = manifestations(:manifestation_00001)
      @manifestation.picture_files.first.attachment.attach(io: File.open(Rails.root.join('app/assets/images/spinner.gif')), filename: 'spinner.gif')
    end

    it "should get show" do
      get iiif_presentation_path(@manifestation, format: :json)
      expect(response).to be_successful
      expect(JSON.parse(response.body)['label']).to eq 'よくわかる最新Webサービス技術の基本と仕組み : 標準Webシステム技術とeコマース基盤技術入門'
    end
  end
end
