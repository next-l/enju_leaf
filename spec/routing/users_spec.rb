require "spec_helper"

describe ProfilesController do
  describe "routing" do

    it "recognizes and generates #new" do
      { get: "/users/sign_in" }.should route_to(controller: "devise/sessions", action: "new")
    end

    it "recognizes and generates #destroy" do
      { delete: "/users/sign_out" }.should route_to(controller: "devise/sessions", action: "destroy")
    end
  end
end
