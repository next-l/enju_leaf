require 'rails_helper'

RSpec.describe "MissionControlController", type: :request do
  describe "GET /jobs" do
    fixtures :all

    describe "When not logged" do
      it "should get jobs" do
        get "/jobs"
        expect(response).to have_http_status(:found)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in users(:user1)
      end

      it "should get jobs" do
        get "/jobs"
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in users(:librarian1)
      end

      it "should get jobs" do
        get "/jobs"
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "When logged in as Administrator" do
      xit "should get jobs" do
        get "/jobs"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
