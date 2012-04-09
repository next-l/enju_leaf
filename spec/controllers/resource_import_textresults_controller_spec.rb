require 'spec_helper'

describe ResourceImportTextresultsController do

  describe "GET 'index'" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "returns http success" do
        get :index
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "returns http success" do
        get :index
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "returns http success" do
        get :index
        response.should_not be_success
      end
    end

    describe "When not logged in" do
      it "returns http success" do
        get :index
        response.should_not be_success
      end
    end
 end
end
