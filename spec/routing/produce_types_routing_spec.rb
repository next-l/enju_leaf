require "spec_helper"

describe ProduceTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/produce_types").should route_to("produce_types#index")
    end

    it "routes to #new" do
      get("/produce_types/new").should route_to("produce_types#new")
    end

    it "routes to #show" do
      get("/produce_types/1").should route_to("produce_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/produce_types/1/edit").should route_to("produce_types#edit", :id => "1")
    end

    it "routes to #create" do
      post("/produce_types").should route_to("produce_types#create")
    end

    it "routes to #update" do
      put("/produce_types/1").should route_to("produce_types#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/produce_types/1").should route_to("produce_types#destroy", :id => "1")
    end

  end
end
