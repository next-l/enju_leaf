require "spec_helper"

describe SeriesStatementMergeListsController do
  describe "routing" do

    it "routes to #index" do
      get("/series_statement_merge_lists").should route_to("series_statement_merge_lists#index")
    end

    it "routes to #new" do
      get("/series_statement_merge_lists/new").should route_to("series_statement_merge_lists#new")
    end

    it "routes to #show" do
      get("/series_statement_merge_lists/1").should route_to("series_statement_merge_lists#show", :id => "1")
    end

    it "routes to #edit" do
      get("/series_statement_merge_lists/1/edit").should route_to("series_statement_merge_lists#edit", :id => "1")
    end

    it "routes to #create" do
      post("/series_statement_merge_lists").should route_to("series_statement_merge_lists#create")
    end

    it "routes to #update" do
      put("/series_statement_merge_lists/1").should route_to("series_statement_merge_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/series_statement_merge_lists/1").should route_to("series_statement_merge_lists#destroy", :id => "1")
    end

  end
end
