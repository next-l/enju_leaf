require "spec_helper"

describe CurrenciesController do
  describe "routing" do

    it "routes to #index" do
      get("/currencies").should route_to("currencies#index")
    end

    it "routes to #new" do
      get("/currencies/new").should route_to("currencies#new")
    end

    it "routes to #show" do
      get("/currencies/1").should route_to("currencies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/currencies/1/edit").should route_to("currencies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/currencies").should route_to("currencies#create")
    end

    it "routes to #update" do
      put("/currencies/1").should route_to("currencies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/currencies/1").should route_to("currencies#destroy", :id => "1")
    end

  end
end
