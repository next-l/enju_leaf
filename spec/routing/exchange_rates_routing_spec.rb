require "spec_helper"

describe ExchangeRatesController do
  describe "routing" do

    it "routes to #index" do
      get("/exchange_rates").should route_to("exchange_rates#index")
    end

    it "routes to #new" do
      get("/exchange_rates/new").should route_to("exchange_rates#new")
    end

    it "routes to #show" do
      get("/exchange_rates/1").should route_to("exchange_rates#show", :id => "1")
    end

    it "routes to #edit" do
      get("/exchange_rates/1/edit").should route_to("exchange_rates#edit", :id => "1")
    end

    it "routes to #create" do
      post("/exchange_rates").should route_to("exchange_rates#create")
    end

    it "routes to #update" do
      put("/exchange_rates/1").should route_to("exchange_rates#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/exchange_rates/1").should route_to("exchange_rates#destroy", :id => "1")
    end

  end
end
