require "rails_helper"

RSpec.describe PeriodicalsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/periodicals").to route_to("periodicals#index")
    end

    it "routes to #new" do
      expect(get: "/periodicals/new").to route_to("periodicals#new")
    end

    it "routes to #show" do
      expect(get: "/periodicals/1").to route_to("periodicals#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/periodicals/1/edit").to route_to("periodicals#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/periodicals").to route_to("periodicals#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/periodicals/1").to route_to("periodicals#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/periodicals/1").to route_to("periodicals#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/periodicals/1").to route_to("periodicals#destroy", id: "1")
    end
  end
end
