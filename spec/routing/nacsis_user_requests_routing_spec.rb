require "spec_helper"

describe NacsisUserRequestsController do
  describe "routing" do

    it "routes to #index" do
      get("/nacsis_user_requests").should route_to("nacsis_user_requests#index")
    end

    it "routes to #new" do
      get("/nacsis_user_requests/new").should route_to("nacsis_user_requests#new")
    end

    it "routes to #show" do
      get("/nacsis_user_requests/1").should route_to("nacsis_user_requests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/nacsis_user_requests/1/edit").should route_to("nacsis_user_requests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/nacsis_user_requests").should route_to("nacsis_user_requests#create")
    end

    it "routes to #update" do
      put("/nacsis_user_requests/1").should route_to("nacsis_user_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/nacsis_user_requests/1").should route_to("nacsis_user_requests#destroy", :id => "1")
    end

  end
end
