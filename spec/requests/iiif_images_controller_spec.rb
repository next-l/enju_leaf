require 'rails_helper'

RSpec.describe "IiifImagesControllers", type: :request do
  describe "GET /show" do
    fixtures :all
    before(:each) do
      @manifestation = manifestations(:manifestation_00001)
    end

    it "should get show" do
      get iiif_image_path(@manifestation, format: :ttl)
      expect(response).to be_successful
      expect(JSON.parse(response.body)['label']).to eq 'よくわかる最新Webサービス技術の基本と仕組み : 標準Webシステム技術とeコマース基盤技術入門'
    end
  end
end
