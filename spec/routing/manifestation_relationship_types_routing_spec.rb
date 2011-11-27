require "spec_helper"

describe ManifestationRelationshipTypesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/manifestation_relationship_types" }.should route_to(:controller => "manifestation_relationship_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/manifestation_relationship_types/new" }.should route_to(:controller => "manifestation_relationship_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/manifestation_relationship_types/1" }.should route_to(:controller => "manifestation_relationship_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/manifestation_relationship_types/1/edit" }.should route_to(:controller => "manifestation_relationship_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/manifestation_relationship_types" }.should route_to(:controller => "manifestation_relationship_types", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/manifestation_relationship_types/1" }.should route_to(:controller => "manifestation_relationship_types", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/manifestation_relationship_types/1" }.should route_to(:controller => "manifestation_relationship_types", :action => "destroy", :id => "1")
    end

  end
end
