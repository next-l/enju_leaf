require "spec_helper"

describe ThemasController do
  describe "routing" do

    it "routes to #index" do
      get("/themas").should route_to("themas#index")
    end

    it "routes to #new" do
      get("/themas/new").should route_to("themas#new")
    end

    it "routes to #show" do
      get("/themas/1").should route_to("themas#show", :id => "1")
    end

    it "routes to #edit" do
      get("/themas/1/edit").should route_to("themas#edit", :id => "1")
    end

    it "routes to #create" do
      post("/themas").should route_to("themas#create")
    end

    it "routes to #update" do
      put("/themas/1").should route_to("themas#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/themas/1").should route_to("themas#destroy", :id => "1")
    end

  end
end
