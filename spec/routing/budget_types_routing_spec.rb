require "spec_helper"

describe BudgetTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/budget_types").should route_to("budget_types#index")
    end

    it "routes to #new" do
      get("/budget_types/new").should route_to("budget_types#new")
    end

    it "routes to #show" do
      get("/budget_types/1").should route_to("budget_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/budget_types/1/edit").should route_to("budget_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/budget_types").should route_to("budget_types#create")
    end

    it "routes to #update" do
      put("/budget_types/1").should route_to("budget_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/budget_types/1").should route_to("budget_types#destroy", :id => "1")
    end

  end
end
