require "spec_helper"

describe SystemConfigurationsController do
  describe "routing" do

    it "routes to #index" do
      get("/system_configurations").should route_to("system_configurations#index")
    end

    it "routes to #new" do
      get("/system_configurations/new").should route_to("system_configurations#new")
    end

    it "routes to #show" do
      get("/system_configurations/1").should route_to("system_configurations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/system_configurations/1/edit").should route_to("system_configurations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/system_configurations").should route_to("system_configurations#create")
    end

    it "routes to #update" do
      put("/system_configurations/1").should route_to("system_configurations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/system_configurations/1").should route_to("system_configurations#destroy", :id => "1")
    end

  end
end
