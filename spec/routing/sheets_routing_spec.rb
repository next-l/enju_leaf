require "spec_helper"

describe SheetsController do
  describe "routing" do

    it "routes to #index" do
      get("/sheets").should route_to("sheets#index")
    end

    it "routes to #new" do
      get("/sheets/new").should route_to("sheets#new")
    end

    it "routes to #show" do
      get("/sheets/1").should route_to("sheets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sheets/1/edit").should route_to("sheets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sheets").should route_to("sheets#create")
    end

    it "routes to #update" do
      put("/sheets/1").should route_to("sheets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sheets/1").should route_to("sheets#destroy", :id => "1")
    end

  end
end
