require 'rails_helper'

RSpec.describe "TwoFactorAuthenticationsControllers", type: :request do
  describe "GET /two_factor_authentication" do
    fixtures :all
    before(:each) do
      sign_in users(:admin)
    end

    it "should get show" do
      get two_factor_authentication_path
      expect(response).to be_successful
    end
  end

  describe "POST /two_factor_authentication" do
    fixtures :all
    before(:each) do
      sign_in users(:admin)
    end

    it "should post" do
      post two_factor_authentication_path
      expect(response).to redirect_to two_factor_authentication_url
    end
  end
end
