require "rails_helper"

RSpec.describe PictureFilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/picture_files").to route_to("picture_files#index")
    end

    it "routes to #new" do
      expect(get: "/picture_files/new").to route_to("picture_files#new")
    end

    it "routes to #show" do
      expect(get: "/picture_files/1").to route_to("picture_files#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/picture_files/1/edit").to route_to("picture_files#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/picture_files").to route_to("picture_files#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/picture_files/1").to route_to("picture_files#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/picture_files/1").to route_to("picture_files#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/picture_files/1").to route_to("picture_files#destroy", id: "1")
    end

    it "routes to #download" do
      expect(get: "/picture_files/1").to route_to("picture_files#download", id: "1")
    end
  end
end
