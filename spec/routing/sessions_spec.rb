require "spec_helper"

describe SessionsController do
  describe "routing" do

    it "recognizes and generates #new" do
      { get: "/sessions/new" }.should route_to(controller: "sessions", action: "new")
    end

    it "recognizes and generates #destroy" do
      { delete: "/logout" }.should route_to(controller: "sessions", action: "destroy")
    end
  end
end
