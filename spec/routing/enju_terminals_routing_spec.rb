require "spec_helper"

describe EnjuTerminalsController do
  describe "routing" do

    it "routes to #index" do
      get("/enju_terminals").should route_to("enju_terminals#index")
    end

    it "routes to #new" do
      get("/enju_terminals/new").should route_to("enju_terminals#new")
    end

    it "routes to #show" do
      get("/enju_terminals/1").should route_to("enju_terminals#show", :id => "1")
    end

    it "routes to #edit" do
      get("/enju_terminals/1/edit").should route_to("enju_terminals#edit", :id => "1")
    end

    it "routes to #create" do
      post("/enju_terminals").should route_to("enju_terminals#create")
    end

    it "routes to #update" do
      put("/enju_terminals/1").should route_to("enju_terminals#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/enju_terminals/1").should route_to("enju_terminals#destroy", :id => "1")
    end

  end
end
