require "spec_helper"

describe ThemesController do
  describe "routing" do

    it "routes to #index" do
      get("/themes").should route_to("themes#index")
    end

    it "routes to #new" do
      get("/themes/new").should route_to("themes#new")
    end

    it "routes to #show" do
      get("/themes/1").should route_to("themes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/themes/1/edit").should route_to("themes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/themes").should route_to("themes#create")
    end

    it "routes to #update" do
      put("/themes/1").should route_to("themes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/themes/1").should route_to("themes#destroy", :id => "1")
    end

  end
end
