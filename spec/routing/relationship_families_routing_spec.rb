require "spec_helper"

describe RelationshipFamiliesController do
  describe "routing" do

    it "routes to #index" do
      get("/relationship_families").should route_to("relationship_families#index")
    end

    it "routes to #new" do
      get("/relationship_families/new").should route_to("relationship_families#new")
    end

    it "routes to #show" do
      get("/relationship_families/1").should route_to("relationship_families#show", :id => "1")
    end

    it "routes to #edit" do
      get("/relationship_families/1/edit").should route_to("relationship_families#edit", :id => "1")
    end

    it "routes to #create" do
      post("/relationship_families").should route_to("relationship_families#create")
    end

    it "routes to #update" do
      put("/relationship_families/1").should route_to("relationship_families#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/relationship_families/1").should route_to("relationship_families#destroy", :id => "1")
    end

  end
end
