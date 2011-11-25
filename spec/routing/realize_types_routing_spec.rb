require "spec_helper"

describe RealizeTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/realize_types").should route_to("realize_types#index")
    end

    it "routes to #new" do
      get("/realize_types/new").should route_to("realize_types#new")
    end

    it "routes to #show" do
      get("/realize_types/1").should route_to("realize_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/realize_types/1/edit").should route_to("realize_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/realize_types").should route_to("realize_types#create")
    end

    it "routes to #update" do
      put("/realize_types/1").should route_to("realize_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/realize_types/1").should route_to("realize_types#destroy", :id => "1")
    end

  end
end
