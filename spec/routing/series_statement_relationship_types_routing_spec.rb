require "spec_helper"

describe SeriesStatementRelationshipTypesController do
  describe "routing" do

    it "routes to #index" do
      get("/series_statement_relationship_types").should route_to("series_statement_relationship_types#index")
    end

    it "routes to #show" do
      get("/series_statement_relationship_types/1").should route_to("series_statement_relationship_types#show", :id => "1")
    end

    it "routes to #edit" do
      get("/series_statement_relationship_types/1/edit").should route_to("series_statement_relationship_types#edit", :id => "1")
    end

    it "routes to #update" do
      put("/series_statement_relationship_types/1").should route_to("series_statement_relationship_types#update", :id => "1")
    end

  end
end
