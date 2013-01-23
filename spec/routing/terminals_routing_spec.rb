require "spec_helper"

describe TerminalsController do
  describe "routing" do

    it "routes to #index" do
      get("/terminals").should route_to("terminals#index")
    end

    it "routes to #new" do
      get("/terminals/new").should route_to("terminals#new")
    end

    it "routes to #show" do
      get("/terminals/1").should route_to("terminals#show", :id => "1")
    end

    it "routes to #edit" do
      get("/terminals/1/edit").should route_to("terminals#edit", :id => "1")
    end

    it "routes to #create" do
      post("/terminals").should route_to("terminals#create")
    end

    it "routes to #update" do
      put("/terminals/1").should route_to("terminals#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/terminals/1").should route_to("terminals#destroy", :id => "1")
    end

  end
end
