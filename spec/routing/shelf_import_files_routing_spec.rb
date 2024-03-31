require "rails_helper"

RSpec.describe ShelfImportFilesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/shelf_import_files").to route_to("shelf_import_files#index")
    end

    it "routes to #new" do
      expect(get: "/shelf_import_files/new").to route_to("shelf_import_files#new")
    end

    it "routes to #show" do
      expect(get: "/shelf_import_files/1").to route_to("shelf_import_files#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/shelf_import_files/1/edit").to route_to("shelf_import_files#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/shelf_import_files").to route_to("shelf_import_files#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/shelf_import_files/1").to route_to("shelf_import_files#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/shelf_import_files/1").to route_to("shelf_import_files#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/shelf_import_files/1").to route_to("shelf_import_files#destroy", id: "1")
    end
  end
end
