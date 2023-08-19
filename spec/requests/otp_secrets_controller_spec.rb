require 'rails_helper'

RSpec.describe "OtpSecretsControllers", type: :request do
  describe "POST /otp_requests" do
    fixtures :all
    before(:each) do
      sign_in users(:admin)
    end

    it "should post" do
      post otp_secret_path
      expect(response).to redirect_to two_factor_authentication_url
    end
  end
end
