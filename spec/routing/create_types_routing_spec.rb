require "spec_helper"

describe CreateTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/create_types").should route_to("create_types#index")
    end

    it "routes to #new" do
      get("/create_types/new").should route_to("create_types#new")
    end

    it "routes to #show" do
      get("/create_types/1").should route_to("create_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/create_types/1/edit").should route_to("create_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/create_types").should route_to("create_types#create")
    end

    it "routes to #update" do
      put("/create_types/1").should route_to("create_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/create_types/1").should route_to("create_types#destroy", :id => "1")
    end

  end
end
