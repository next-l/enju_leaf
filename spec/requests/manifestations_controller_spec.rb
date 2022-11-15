require 'rails_helper'

RSpec.describe "ManifestationsController", type: :request do
  describe "GET /manifestations/1" do
    fixtures :all
    before(:each) do
      @manifestation = manifestations(:manifestation_00023)
    end

    it 'should not download an attachment file' do
      @manifestation.attachment.attach(io: File.open(Rails.root.join('app/assets/images/spinner.gif')), filename: 'spinner.gif')
      expect { get rails_blob_path(@manifestation.attachment) }.to raise_error(Pundit::NotAuthorizedError)
      expect { get rails_storage_proxy_path(@manifestation.attachment) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
