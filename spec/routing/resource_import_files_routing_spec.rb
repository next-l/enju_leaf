require "spec_helper"

describe UserImportFilesController do
  describe "routing" do

    it "routes to #index" do
      get("/user_import_files").should route_to("user_import_files#index")
    end

    it "routes to #new" do
      get("/user_import_files/new").should route_to("user_import_files#new")
    end

    it "routes to #show" do
      get("/user_import_files/1").should route_to("user_import_files#show", id: "1")
    end

    it "routes to #edit" do
      get("/user_import_files/1/edit").should route_to("user_import_files#edit", id: "1")
    end

    it "routes to #create" do
      post("/user_import_files").should route_to("user_import_files#create")
    end

    it "routes to #update" do
      put("/user_import_files/1").should route_to("user_import_files#update", id: "1")
    end

    it "routes to #destroy" do
      delete("/user_import_files/1").should route_to("user_import_files#destroy", id: "1")
    end

  end
end
