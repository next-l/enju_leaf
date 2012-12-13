require "spec_helper"

describe NumberingsController do
  describe "routing" do

    it "routes to #index" do
      get("/numberings").should route_to("numberings#index")
    end

    it "routes to #new" do
      get("/numberings/new").should route_to("numberings#new")
    end

    it "routes to #show" do
      get("/numberings/1").should route_to("numberings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/numberings/1/edit").should route_to("numberings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/numberings").should route_to("numberings#create")
    end

    it "routes to #update" do
      put("/numberings/1").should route_to("numberings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/numberings/1").should route_to("numberings#destroy", :id => "1")
    end

  end
end
