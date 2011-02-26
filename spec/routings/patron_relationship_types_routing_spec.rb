require "spec_helper"

describe PatronRelationshipTypesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/patron_relationship_types" }.should route_to(:controller => "patron_relationship_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/patron_relationship_types/new" }.should route_to(:controller => "patron_relationship_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/patron_relationship_types/1" }.should route_to(:controller => "patron_relationship_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/patron_relationship_types/1/edit" }.should route_to(:controller => "patron_relationship_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/patron_relationship_types" }.should route_to(:controller => "patron_relationship_types", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/patron_relationship_types/1" }.should route_to(:controller => "patron_relationship_types", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/patron_relationship_types/1" }.should route_to(:controller => "patron_relationship_types", :action => "destroy", :id => "1")
    end

  end
end
