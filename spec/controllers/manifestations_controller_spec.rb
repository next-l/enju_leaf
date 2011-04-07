require 'spec_helper'

describe ManifestationsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations" do
        get :index
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in oai format" do
        get :index, :format => 'oai', :verb => 'ListRecords'
        assigns(:manifestations).should_not be_nil
      end

      it "assigns all manifestations as @manifestations in sru format" do
        get :index, :format => 'sru'
        assigns(:manifestations).should be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested manifestation as @manifestation" do
        get :show, :id => 1
        assigns(:manifestation).should eq(Manifestation.find(1))
      end
    end
  end
end
