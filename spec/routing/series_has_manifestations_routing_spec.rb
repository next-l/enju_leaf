require "spec_helper"

describe SeriesHasManifestationsController do
  describe "routing" do

    it "routes to #index" do
      get("/series_has_manifestations").should route_to("series_has_manifestations#index")
    end

    it "routes to #new" do
      get("/series_has_manifestations/new").should route_to("series_has_manifestations#new")
    end

    it "routes to #show" do
      get("/series_has_manifestations/1").should route_to("series_has_manifestations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/series_has_manifestations/1/edit").should route_to("series_has_manifestations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/series_has_manifestations").should route_to("series_has_manifestations#create")
    end

    it "routes to #update" do
      put("/series_has_manifestations/1").should route_to("series_has_manifestations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/series_has_manifestations/1").should route_to("series_has_manifestations#destroy", :id => "1")
    end

  end
end
